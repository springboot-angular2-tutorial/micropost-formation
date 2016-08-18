variable "security_groups" {
  description = "Security groups for db servers"
  default = []
}

variable "subnets" {
  description = "Subnets for db servers"
  default = []
}

variable "snapshot_identifier" {
  description = "Initial snapshot to restore"
}
