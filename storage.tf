data "oci_objectstorage_namespace" "osn" {}

resource "oci_objectstorage_bucket" "bucket" {
  compartment_id = var.compartment_ocid
  name           = "my-static-assets-bucket"
  namespace      = data.oci_objectstorage_namespace.osn.namespace
  storage_tier   = "Standard"
}
