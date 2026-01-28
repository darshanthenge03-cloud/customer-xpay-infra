variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vm_admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "static_web_app_name" {}

variable "tags" {
  type = map(string)
}
