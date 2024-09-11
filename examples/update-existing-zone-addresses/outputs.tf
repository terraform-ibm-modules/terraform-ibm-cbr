# # ##############################################################################
# # # Outputs
# # ##############################################################################

output "vpc_id" {
  value       = resource.ibm_is_vpc.example_vpc.id
  description = "VPC id"
}

output "new_vpc_id" {
  value       = resource.ibm_is_vpc.example_new_vpc.id
  description = "New VPC id"
}

output "vpc_crn" {
  value       = resource.ibm_is_vpc.example_vpc.crn
  description = "VPC crn"
}

output "new_vpc_crn" {
  value       = resource.ibm_is_vpc.example_new_vpc.crn
  description = "New VPC crn"
}

output "account_id" {
  description = "account id"
  value       = data.ibm_iam_account_settings.iam_account_settings.id
}

output "zone_name" {
  value       = module.ibm_cbr_zone.zone_names
  description = "cbr_zone name"
}

output "zone_description" {
  value       = module.ibm_cbr_zone.zone_description
  description = "cbr_zone description"
}

output "zone_id" {
  value       = module.ibm_cbr_zone.zone_id
  description = "cbr_zone id"
}

output "zone_crn" {
  value       = module.ibm_cbr_zone.zone_crn
  description = "cbr_zone crn"
}

output "zone_href" {
  value       = module.ibm_cbr_zone.zone_href
  description = "cbr_zone href"
}
