###
# Deploy Vault server cluster
###
module "vault_cluster" {
  source = "github.com/hashicorp/terraform-aws-vault//modules/vault-cluster?ref=v0.13.8"

  cluster_name  = var.vault_cluster_name
  cluster_size  = var.vault_cluster_size
  instance_type = var.vault_instance_type

  enable_auto_unseal      = var.enable_auto_unseal
  auto_unseal_kms_key_arn = aws_kms_key.vault.arn

  ami_id    = var.ami_id
  user_data = data.template_file.user_data_vault_cluster.rendered

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  health_check_type = "EC2"

  # To make testing easier, we allow requests from any IP address here but in a production deployment, we *strongly*
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.

  allowed_ssh_cidr_blocks              = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks          = ["0.0.0.0/0"]
  allowed_inbound_security_group_ids   = []
  allowed_inbound_security_group_count = 0
  ssh_key_name                         = var.ssh_key_name
}

# Consul iam policies to allow vault cluster to discover consul backend
module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.7.7"

  iam_role_id = module.vault_cluster.iam_role_id
}

# This script will configure and start Vault
data "template_file" "user_data_vault_cluster" {
  template = file("${path.module}/templates/user-data-vault.sh")

  vars = {
    aws_region               = var.region
    consul_cluster_tag_key   = var.consul_cluster_tag_key
    consul_cluster_tag_value = var.consul_cluster_name
    auto_unseal_kms_key_id   = aws_kms_key.vault.key_id
  }
}

# Consul sg for allowing internal communications between agents and servers
module "security_group_rules" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-client-security-group-rules?ref=v0.7.7"

  security_group_id = module.vault_cluster.security_group_id

  # To make testing easier, we allow requests from any IP address here but in a production deployment, we *strongly*
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.

  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
}

# Deploy an elb for public access to vault
module "vault_elb" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "github.com/hashicorp/terraform-aws-vault//modules/vault-elb?ref=v0.13.8"
  #   source = "./modules/vault-elb"

  name = var.vault_cluster_name

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # Associate the ELB with the instances created by the Vault Autoscaling group
  vault_asg_name = module.vault_cluster.asg_name

  # To make testing easier, we allow requests from any IP address here but in a production deployment, we *strongly*
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]

  health_check_protocol = "HTTPS"

  # In order to access Vault over HTTPS, we need a domain name that matches the TLS cert
  create_dns_entry = var.create_dns_entry

  # Terraform conditionals are not short-circuiting, so we use join as a workaround to avoid errors when the
  # aws_route53_zone data source isn't actually set: https://github.com/hashicorp/hil/issues/50
  #   hosted_zone_id = var.create_dns_entry ? join("", data.aws_route53_zone.selected.*.zone_id) : ""

  domain_name = var.vault_domain_name
}

###
# Deploy consul server cluster
###
module "consul_cluster" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.7.7"

  cluster_name  = var.consul_cluster_name
  cluster_size  = var.consul_cluster_size
  instance_type = var.consul_instance_type

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = var.consul_cluster_tag_key
  cluster_tag_value = var.consul_cluster_name

  ami_id    = var.ami_id
  user_data = data.template_file.user_data_consul.rendered

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = var.ssh_key_name
}

# This script will configure and start Consul
data "template_file" "user_data_consul" {
  template = file("${path.module}/templates/user-data-consul.sh")

  vars = {
    consul_cluster_tag_key   = var.consul_cluster_tag_key
    consul_cluster_tag_value = var.consul_cluster_name
  }
}

###
# Vault auto-unseal resources
###
resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 7

  tags = {
    Name = "vault-kms-unseal-${random_id.cluster_name.hex}"
  }
}

###
# define the aws network to place the provisioned ec2 resources
###
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${random_id.cluster_name.hex}-vpc"

  cidr = "10.${var.subnet_second_octet}.0.0/16"

  azs = data.aws_availability_zones.available.names
  private_subnets = [
    for num in range(0, length(data.aws_availability_zones.available.names)) :
    cidrsubnet("10.${var.subnet_second_octet}.1.0/16", 8, 1 + num)
  ]
  public_subnets = [
    for num in range(0, length(data.aws_availability_zones.available.names)) :
    cidrsubnet("10.${var.subnet_second_octet}.101.0/16", 8, 101 + num)
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name = "hc-jb-name-public"
  }

  # tags = local.tags

  vpc_tags = {
    Name    = "${random_id.cluster_name.hex}-vpc"
    Purpose = "vault"
  }
}
