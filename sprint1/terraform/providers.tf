terraform {
  required_version = ">= 0.13"

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.108.1"
    }
  }
}

provider "yandex" {
  zone      = var.zone[0]
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  token     = var.yandex_cloud_token
}
