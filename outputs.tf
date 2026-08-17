output "instance_public_ip" {
  description = "Public IP address of the exit node."
  value       = oci_core_instance.exit_node.public_ip
}

output "instance_id" {
  description = "OCID of the compute instance."
  value       = oci_core_instance.exit_node.id
}

output "ssh_command" {
  description = "Convenience SSH command."
  value       = "ssh ubuntu@${oci_core_instance.exit_node.public_ip}"
}
