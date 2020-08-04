module "vault_cluster" {
  source = "github.com/hashicorp/terraform-aws-vault//modules/private-tls-cert?ref=v0.13.8"

  ca_public_key_file_path = "${path.module}/ca.crt.pem"
  public_key_file_path    = "${path.module}/vault.crt.pem"
  private_key_file_path   = "${path.module}/vault.key.pem"
  owner                   = var.owner
  organization_name       = "IT"
  ca_common_name          = "acme.co"
  common_name             = "acme.co"
  dns_names               = var.dns_names
  ip_addresses            = var.ip_addresses
  validity_period_hours   = var.validity_period_hours
}
