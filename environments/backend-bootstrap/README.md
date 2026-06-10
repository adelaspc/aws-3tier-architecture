# Terraform Backend Bootstrap

Creates the S3 bucket used by the `dev` Terraform backend. State locking uses
Terraform's native S3 lockfile support.

Run this stack once before initializing `environments/dev` with the remote backend:

```bash
cd environments/backend-bootstrap
terraform init
terraform apply
```

Then copy the output values into `environments/dev/backend.hcl` based on `backend.hcl.example` and initialize the dev stack:

```bash
cd ../dev
terraform init -backend-config=backend.hcl
```

Keep this bootstrap stack separate from the application stack so `terraform destroy` in `environments/dev` does not delete the remote state bucket.
