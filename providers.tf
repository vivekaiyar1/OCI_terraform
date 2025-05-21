provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

locals {
  cluster_id             = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
}
