variable "unique_suffix" {
  type        = string
  description = "The unique suffix to apply to all resource names."
}

variable "vpc_id" {
  type        = string
  description = "The VPC to create security groups in."
}

variable "server_port" {
  type        = number
  description = "The port that the server listens on."
}

variable "server_security_group_id" {
  type        = string
  description = "The security group ID of the server pod."
}
