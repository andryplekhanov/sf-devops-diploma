# Создание сервисной ВМ и развертывание с неё kubernetes кластера
module "kubernetes_cluster" {
  source           = "./modules/srv"
  vpc_network_id   = yandex_vpc_network.k8s-network.id
  vpc_subnet1_id   = yandex_vpc_subnet.k8s-subnet-1.id
  vpc_subnet2_id   = yandex_vpc_subnet.k8s-subnet-2.id
  vpc_subnet3_id   = yandex_vpc_subnet.k8s-subnet-3.id
  name             = "srv"
  zone             = var.zone[0]
  yandex_folder_id = var.folder_id
  yandex_cloud_id  = var.cloud_id
  yandex_token     = var.yandex_cloud_token
}