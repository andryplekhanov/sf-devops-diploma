output "external_ip_address_srv" {
  value = yandex_compute_instance.srv[*].network_interface.0.nat_ip_address
}