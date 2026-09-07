# Security Policy

## Supported Versions

This repository is an ephemeral infrastructure and application demo rather than
a versioned production product. Security fixes are applied only to the latest
revision of the default branch. Older commits, tags, forks, and deployed copies
are not supported.

## Reporting a Vulnerability

Please do not disclose suspected vulnerabilities in a public issue, discussion,
or pull request.

Use the repository's **Security** tab and select **Report a vulnerability** to
submit a private report. Private vulnerability reporting will be enabled when
the repository becomes public. If that option is unavailable, contact the
repository owner privately through the contact information on their GitHub
profile.

Include, where possible:

- the affected component and revision;
- reproduction steps or a minimal proof of concept;
- the expected impact and required preconditions;
- any suggested mitigation;
- whether the issue is already public or has been shared elsewhere.

Do not include real credentials, personal data, or data belonging to third
parties. Use synthetic test data and stop testing if it could affect an AWS
account, deployed infrastructure, or another user.

You should receive an initial acknowledgement within seven days. Validation,
remediation, and disclosure timelines depend on severity and complexity. Please
allow a reasonable remediation period before publishing details.

## Scope

Reports about this repository's source code, Terraform configuration, container
images, CI/CD configuration, or documented deployment model are in scope.
Vulnerabilities in third-party services or dependencies should also be reported
to the relevant upstream maintainer when appropriate.

The demo deliberately documents several cost and production-readiness
trade-offs in [docs/security-and-tradeoffs.md](docs/security-and-tradeoffs.md).
A documented limitation is not automatically a vulnerability, but reports that
show an undocumented or more serious impact are welcome.
