variable "resource_group_name" {
  type        = string
  description = "Name of resource group"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of virtual network"
}

variable "subnet_name" {
  type        = string
  description = "Name of subnet"
}

variable "availability_set_name" {
  type        = string
  description = "Name of availability set"
}

variable "admin_username" {
  type        = string
  description = "Admin username"
  sensitive   = true
}

variable "admin_password" {
  type        = string
  description = "Admin password"
  sensitive   = true
}
