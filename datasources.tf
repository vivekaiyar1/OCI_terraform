data "oci_core_images" "node_pool_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.instanceShape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_containerengine_cluster_option" "oke" {
  cluster_option_id = "all"
}
data "oci_containerengine_node_pool_option" "oke" {
  node_pool_option_id = "all"
}
data "oci_containerengine_clusters" "oke" {
  compartment_id = var.compartment_ocid
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Gets kubeconfig
data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = oci_containerengine_cluster.oke_cluster.id

  depends_on = [oci_containerengine_node_pool.oke_node_pool]
}

# OCI Services
## Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}
