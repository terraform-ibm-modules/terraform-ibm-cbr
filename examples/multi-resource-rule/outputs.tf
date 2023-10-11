##############################################################################
# Outputs
##############################################################################

output "cos_guid" {
  value       = module.cos_instance_and_bucket.cos_instance_guid
  description = "COS guid"
}

output "bucket_guid" {
  value       = module.cos_instance_and_bucket.bucket_id
  description = "COS bucket guid"
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "Resource group ID"
}
