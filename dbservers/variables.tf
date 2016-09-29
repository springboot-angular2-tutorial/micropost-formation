variable "security_groups" {
  type = "list"
  description = "Security groups for db servers"
  default = []
}

variable "subnets" {
  type = "list"
  description = "Subnets for db servers"
  default = []
}

variable "snapshot_identifier" {
  description = "Initial snapshot to restore"
}
