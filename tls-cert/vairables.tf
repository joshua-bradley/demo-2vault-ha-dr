variable "owner" {
  description = "The OS user who should be given ownership over the certificate files."
  type        = string
  default     = "vault"
}

variable "dns_names" {
  description = "List of DNS names for which the certificate will be valid (e.g. vault.service.consul, foo.example.com)."
  type        = list(string)
  default     = ["*.*.elb.amazonaws.com", "vault.service.consul", "vault.example.com"]
}

variable "ip_addresses" {
  description = "List of IP addresses for which the certificate will be valid (e.g. 127.0.0.1)."
  type        = list(string)
  default     = ["127.0.0.1"]
}

variable "validity_period_hours" {
  description = "The number of hours after initial issuing that the certificate will become invalid."
  type        = number
  default     = 87600
}
