output "external_ip_address_srv" {
  value = module.kubernetes_cluster[*].external_ip_address_srv
}