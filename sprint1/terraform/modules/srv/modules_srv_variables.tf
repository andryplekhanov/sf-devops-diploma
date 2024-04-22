variable "instance_family_image" {
  description = "Instance image"
  type        = string
  default     = "ubuntu-2004-lts"
}

variable "vpc_network_id" {
  description = "VPC network id"
  type        = string
}

variable "vpc_subnet1_id" {
  description = "VPC subnet 1 id"
  type        = string
}

variable "vpc_subnet2_id" {
  description = "VPC subnet 2 id"
  type        = string
}

variable "vpc_subnet3_id" {
  description = "VPC subnet 3 id"
  type        = string
}

variable "yandex_folder_id" {
  description = "yc_folder_id"
  type        = string
}

variable "yandex_cloud_id" {
  description = "yc_cloud_id"
  type        = string
}

variable "yandex_token" {
  description = "yc_token"
  type        = string
}

variable "zone" {
  description = "default zone"
  type        = string
}

variable "name" {
  description = "default name for instance"
  type        = string
  default     = "instance"
}

variable "cores" {
  description = "default cores number"
  type        = number
  default     = 4
}

variable "memory" {
  description = "default memory number"
  type        = number
  default     = 12
}

variable "core_fraction" {
  description = "default core_fraction number"
  type        = number
  default     = 100
}

variable "is_preemptible" {
  description = "default is_preemptible"
  type        = bool
  default     = false
}

variable "nat" {
  description = "default nat"
  type        = bool
  default     = true
}


variable "ssh_credentials" {
  description = "Credentials for connect to instances"
  type        = object({
    user        = string
    private_key = string
    pub_key     = string
  })
  default     = {
    user        = "ubuntu"
    private_key = "~/.ssh/id_rsa"
    pub_key     = "~/.ssh/id_rsa.pub"
  }
}
