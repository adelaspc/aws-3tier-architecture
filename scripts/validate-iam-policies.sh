#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <terraform-plan-file>" >&2
  exit 2
fi

plan_file=$1
plan_dir=$(dirname "$plan_file")
plan_name=$(basename "$plan_file")
findings_file=$(mktemp)
trap 'rm -f "$findings_file"' EXIT

validate_policy() {
  local policy_type=$1
  local resource_type=$2
  local policy_document=$3
  local -a args=(
    accessanalyzer validate-policy
    --policy-type "$policy_type"
    --policy-document "$policy_document"
    --output json
  )

  if [[ -n "$resource_type" ]]; then
    args+=(--validate-policy-resource-type "$resource_type")
  fi

  aws "${args[@]}" > "$findings_file"
  jq -e '[.findings[] | select(.findingType == "ERROR")] | length == 0' "$findings_file" > /dev/null
}

plan_json=$(terraform -chdir="$plan_dir" show -json "$plan_name")

mapfile -t identity_policies < <(
  jq -r '
    def modules: ., (.child_modules[]? | modules);
    .planned_values.root_module | modules | .resources[]? |
    select(.type? == "aws_iam_policy") |
    .values.policy? |
    select(type == "string") |
    @base64
  ' <<< "$plan_json"
)

if [[ ${#identity_policies[@]} -ne 3 ]]; then
  echo "Expected three IAM permission policies in the bootstrap plan; found ${#identity_policies[@]}." >&2
  exit 1
fi

for encoded_policy in "${identity_policies[@]}"; do
  validate_policy "IDENTITY_POLICY" "" "$(printf '%s' "$encoded_policy" | base64 --decode)"
done

mapfile -t trust_policies < <(
  jq -r '
    def modules: ., (.child_modules[]? | modules);
    .planned_values.root_module | modules | .resources[]? |
    select(.type? == "aws_iam_role") |
    .values.assume_role_policy? |
    select(type == "string") |
    @base64
  ' <<< "$plan_json"
)

if [[ ${#trust_policies[@]} -ne 3 ]]; then
  echo "Expected three IAM trust policies in the bootstrap plan; found ${#trust_policies[@]}." >&2
  exit 1
fi

for encoded_policy in "${trust_policies[@]}"; do
  validate_policy "RESOURCE_POLICY" "AWS::IAM::AssumeRolePolicyDocument" "$(printf '%s' "$encoded_policy" | base64 --decode)"
done

echo "IAM Access Analyzer validation passed."
