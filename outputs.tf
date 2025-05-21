output "kubeconfig_for_kubectl" {
  value       = "export KUBECONFIG=./generated/kubeconfig"
  description = "If using Terraform locally, this command set KUBECONFIG environment variable to run kubectl locally"
}
output "generated_private_key_pem" {
  value     = var.generate_public_ssh_key ? tls_private_key.oke_worker_node_ssh_key.private_key_pem : "No Keys Auto Generated"
  sensitive = true
}