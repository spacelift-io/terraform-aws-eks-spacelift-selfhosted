variable "aws_region" {
  type = string
}

variable "server_domain" {
  type        = string
  description = "The domain that Spacelift is being hosted on without protocol and port. Eg.: 'spacelift.mycorp.io'."
}

variable "vcs_gateway_domain" {
  type        = string
  description = "The domain for the VCS Gateway external endpoint without protocol and port. Eg.: 'vcs-gateway.mycorp.io'."
}

variable "vcs_gateway_acm_arn" {
  type        = string
  description = "AWS Certificate Manager ARN for the VCS Gateway load balancer."
}
