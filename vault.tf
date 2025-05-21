resource "oci_kms_vault" "vault" {
  compartment_id = var.compartment_ocid
  display_name   = "secrets_vault"
  vault_type     = "DEFAULT"

}