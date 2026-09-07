# RDS Module

Creates the private RDS MySQL instance used by the application tier.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_db_instance.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Initial allocated storage in GiB for the RDS instance. | `number` | `20` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether RDS modifications are applied immediately instead of during the next maintenance window. | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain automated RDS backups. | `number` | `7` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Initial database name created by RDS. | `string` | `"deployment_notes"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | Name of the DB subnet group used by the RDS instance. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether deletion protection is enabled for the RDS instance. | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine used by the RDS instance. | `string` | `"mysql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | MySQL engine version for the RDS instance. | `string` | `"8.0"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name used for resource names and tags. | `string` | n/a | yes |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | Optional final snapshot identifier used when skip\_final\_snapshot is false. | `string` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | RDS instance class. | `string` | `"db.t3.micro"` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Master username for the RDS instance. | `string` | `"deployment_admin"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Upper storage autoscaling limit in GiB for the RDS instance. | `number` | `100` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether to enable Multi-AZ deployment for RDS. | `bool` | `true` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used for resource names and tags. | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Security group ID attached to the RDS instance. | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Whether to skip a final snapshot when destroying the RDS instance. | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type for the RDS instance. | `string` | `"gp3"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | DNS address of the RDS instance. |
| <a name="output_master_user_secret_arn"></a> [master\_user\_secret\_arn](#output\_master\_user\_secret\_arn) | ARN of the AWS-managed RDS master user secret. |
| <a name="output_master_username"></a> [master\_username](#output\_master\_username) | Master username for the RDS instance. |
| <a name="output_port"></a> [port](#output\_port) | Port of the RDS instance. |
<!-- END_TF_DOCS -->
