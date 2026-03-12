###############################################################################
# Compute Module Outputs
###############################################################################

output "velintra_os_instance_id" {
  description = "Instance ID for velintraOS"
  value       = aws_instance.velintra_os.id
}

output "velintra_os_private_ip" {
  description = "Private IP of velintraOS"
  value       = aws_instance.velintra_os.private_ip
}

output "svcs_instance_id" {
  description = "Instance ID for svcs.the16oracles.io"
  value       = aws_instance.svcs_the16oracles_io.id
}

output "svcs_private_ip" {
  description = "Private IP of svcs.the16oracles.io"
  value       = aws_instance.svcs_the16oracles_io.private_ip
}

output "svcs_elastic_ip" {
  description = "Elastic IP for svcs.the16oracles.io"
  value       = aws_eip.svcs_the16oracles_io.public_ip
}
