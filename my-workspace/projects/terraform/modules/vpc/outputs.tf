###############################################################################
# VPC Module Outputs
###############################################################################

output "vpc_id" {
  description = "Default VPC ID"
  value       = aws_default_vpc.default.id
}

output "subnet_ids" {
  description = "List of all default subnet IDs"
  value = [
    aws_default_subnet.us_east_1a.id,
    aws_default_subnet.us_east_1b.id,
    aws_default_subnet.us_east_1c.id,
    aws_default_subnet.us_east_1d.id,
    aws_default_subnet.us_east_1e.id,
    aws_default_subnet.us_east_1f.id,
  ]
}

output "subnet_id_us_east_1a" {
  description = "Subnet ID for us-east-1a"
  value       = aws_default_subnet.us_east_1a.id
}

output "subnet_az_us_east_1a" {
  description = "Availability zone for us-east-1a subnet"
  value       = aws_default_subnet.us_east_1a.availability_zone
}

output "sg_velintra_id" {
  description = "Security group ID for sg_velintra"
  value       = aws_security_group.sg_velintra.id
}

output "sg_t16o_v1_services_id" {
  description = "Security group ID for t16o_v1_services_sg"
  value       = aws_security_group.t16o_v1_services_sg.id
}

output "sg_launch_wizard_1_id" {
  description = "Security group ID for launch-wizard-1"
  value       = aws_security_group.launch_wizard_1.id
}

output "sg_launch_wizard_2_id" {
  description = "Security group ID for launch-wizard-2"
  value       = aws_security_group.launch_wizard_2.id
}

output "default_security_group_id" {
  description = "Default security group ID"
  value       = aws_default_security_group.default.id
}

output "internet_gateway_id" {
  description = "Internet gateway ID"
  value       = aws_internet_gateway.default.id
}

output "default_route_table_id" {
  description = "Default route table ID"
  value       = aws_default_route_table.default.id
}
