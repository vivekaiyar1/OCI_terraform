resource "oci_objectstorage_bucket" "bucket" {
  compartment_id = var.compartment_ocid
  name           = "my-static-assets-bucket"
  namespace      = "app"
  storage_tier   = "Standard"
}
