variable "subnet_id" {
  description = "Public subnet for bastion server"
}

variable "security_groups" {
  type = "list"
  description = "Security groups for bastion server"
  default = []
}

variable "key_name" {
  description = "SSH key to login to bastion server"
}