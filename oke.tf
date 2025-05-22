resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = "test-cluster"
  vcn_id             = oci_core_virtual_network.oke_vcn.id

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = oci_core_subnet.oke_k8s_subnet.id
    nsg_ids              = []
  }
  options {
    service_lb_subnet_ids = [oci_core_subnet.oke_lb_subnet.id]
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
    }
    admission_controller_options {
      is_pod_security_policy_enabled = var.cluster_options_admission_controller_options_is_pod_security_policy_enabled
    }
    kubernetes_network_config {
      services_cidr = lookup(var.network_cidrs, "KUBERNETES-SERVICE-CIDR")
      pods_cidr     = lookup(var.network_cidrs, "PODS-CIDR")
    }
  }

}

resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = var.node_pool_name
  node_shape         = var.instanceShape
  ssh_public_key     = var.generate_public_ssh_key ? tls_private_key.oke_worker_node_ssh_key.public_key_openssh : var.public_ssh_key

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ADs.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = oci_core_subnet.oke_k8s_subnet.id
      }
    }
    size = 3
  }

  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      ocpus         = var.ocpus
      memory_in_gbs = var.memory
    }
  }

  node_source_details {
    source_type             = "IMAGE"
    image_id                = lookup(data.oci_core_images.node_pool_images.images[0], "id")
    boot_volume_size_in_gbs = var.node_pool_boot_volume_size_in_gbs
  }

  initial_node_labels {
    key   = "name"
    value = var.node_pool_name
  }
}

# Local kubeconfig for when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "oke_kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke.content
  filename = "${path.module}/generated/kubeconfig"
}

# Generate ssh keys to access Worker Nodes, if generate_public_ssh_key=true, applies to the pool
resource "tls_private_key" "oke_worker_node_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Checks if is using Flexible Compute Shapes
locals {
  # Checks if is using Flexible Compute Shapes
  is_flexible_node_shape = contains(split(".", var.instanceShape), "Flex")
}