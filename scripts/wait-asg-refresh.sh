#!/usr/bin/env bash
set -euo pipefail

ASG_NAME="${1:-}"
POLL_SECONDS="${POLL_SECONDS:-15}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-80}"
INSTANCE_WARMUP="${INSTANCE_WARMUP:-120}"
MIN_HEALTHY_PERCENTAGE="${MIN_HEALTHY_PERCENTAGE:-100}"

if [ -z "${ASG_NAME}" ]; then
  echo "Usage: $0 <asg-name>" >&2
  exit 2
fi

PREFERENCES="$(cat <<EOF
{
  "MinHealthyPercentage": ${MIN_HEALTHY_PERCENTAGE},
  "InstanceWarmup": ${INSTANCE_WARMUP},
  "SkipMatching": false
}
EOF
)"

REFRESH_ID="$(aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "${ASG_NAME}" \
  --preferences "${PREFERENCES}" \
  --query "InstanceRefreshId" \
  --output text)"

echo "Started instance refresh ${REFRESH_ID} for ${ASG_NAME}"

for attempt in $(seq 1 "${MAX_ATTEMPTS}"); do
  REFRESH_JSON="$(aws autoscaling describe-instance-refreshes \
    --auto-scaling-group-name "${ASG_NAME}" \
    --instance-refresh-ids "${REFRESH_ID}" \
    --output json)"

  STATUS="$(echo "${REFRESH_JSON}" | jq -r '.InstanceRefreshes[0].Status')"
  PERCENTAGE="$(echo "${REFRESH_JSON}" | jq -r '.InstanceRefreshes[0].PercentageComplete // 0')"
  REMAINING="$(echo "${REFRESH_JSON}" | jq -r '.InstanceRefreshes[0].InstancesToUpdate // "unknown"')"
  REASON="$(echo "${REFRESH_JSON}" | jq -r '.InstanceRefreshes[0].StatusReason // ""')"

  case "${STATUS}" in
    Successful)
      echo "Instance refresh ${REFRESH_ID} completed successfully"
      exit 0
      ;;

    Failed|Cancelled|RollbackSuccessful|RollbackFailed)
      echo "Instance refresh ${REFRESH_ID} ended with status ${STATUS}" >&2

      if [ -n "${REASON}" ]; then
        echo "Reason: ${REASON}" >&2
      fi

      echo "${REFRESH_JSON}" | jq .
      exit 1
      ;;
  esac

  echo "Instance refresh ${REFRESH_ID} status: ${STATUS}; progress: ${PERCENTAGE}%; remaining: ${REMAINING}; attempt ${attempt}/${MAX_ATTEMPTS}"

  if [ -n "${REASON}" ]; then
    echo "Status reason: ${REASON}"
  fi

  sleep "${POLL_SECONDS}"
done

echo "Timed out waiting for instance refresh ${REFRESH_ID}" >&2

aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name "${ASG_NAME}" \
  --instance-refresh-ids "${REFRESH_ID}" \
  --output json

exit 1