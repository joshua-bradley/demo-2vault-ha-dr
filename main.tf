###
# DEPLOY A VAULT SERVER CLUSTER, AN ELB, AND A CONSUL SERVER CLUSTER IN AWS
# This example uses the hashicorp vault-cluster and vault-elb modules to
# deploy a Vault cluster in AWS with an Elastic Load Balancer (ELB) in front
# of it. This cluster uses a seperate Consul cluster as its storage backend.
###

###
# Requirements for the terraform provisioner
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
###
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  # version = "~> 2.5"
  version = "~> 3.0"
  region  = var.region
}

###

resource "random_id" "suffix_id" {
  byte_length = 4
}

# Local for tag to attach to all items
locals {
  tags = merge(
    var.standard_tags,
    {
      "ClusterName" = "${var.prefix}-cluster-${random_id.suffix_id.hex}"
    },
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {
}
