resource "oci_load_balancer_load_balancer" "lb" {
  compartment_id = var.compartment_ocid
  display_name   = "mushop-${random_string.deploy_id.result}"
  shape          = "Flexible"
  subnet_ids     = [oci_core_subnet.oke_lb_subnet.id]
  is_private     = "false"

  shape_details {
      minimum_bandwidth_in_mbps = var.lb_shape_details_minimum_bandwidth_in_mbps
      maximum_bandwidth_in_mbps = var.lb_shape_details_maximum_bandwidth_in_mbps
  }
}

resource "oci_load_balancer_backend_set" "backend_set" {
  name             = "mushop-${random_string.deploy_id.result}"
  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  policy           = "IP_HASH"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/api/health"
    return_code         = 200
    interval_ms         = 5000
    timeout_in_millis   = 2000
    retries             = 5
  }
}

resource "oci_load_balancer_backend" "backend" {
  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  backendset_name  = oci_load_balancer_backend_set.backend_set.name
  ip_address       = oci_containerengine_node_pool.oke_node_pool.nodes[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1

}

resource "oci_load_balancer_listener" "listener_443" {
  load_balancer_id         = oci_load_balancer_load_balancer.lb.id
  default_backend_set_name = oci_load_balancer_backend_set.backend_set.name
  name                     = "https-listener"
  port                     = 443
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }
}