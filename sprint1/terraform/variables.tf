variable "cloud_id" {
  description = "Default cloud ID in yandex cloud"
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "Default folder ID in yandex cloud"
  type        = string
  default     = ""
}

variable "yandex_cloud_token" {
  type        = string
  default     = ""
  description = "Default cloud token in yandex cloud"
  sensitive   = true
}

variable "zone" {
  description = "Use specific availability zone"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}
