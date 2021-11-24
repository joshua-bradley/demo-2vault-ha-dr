# these are required parameters to deploy vault cluster with this repository
region = "us-west-2"
ami_id = "ami-06b29993f31af5132"
ssh_key_name = "hc-west-2-jb-2020"
prefix = "hc-jb"

# optional parameters to customize the vault cluster deployment

# networking
# create_dns_entry = false
# hosted_zone_domain_name = ""
# vault_domain_name = ""
# subnet_second_octet = ""

# vault cluster attributes
# vault_cluster_name = ""
# vault_cluster_size = 1
# vault_instance_type = ""
# vault_lb_port = ""
# enable_auto_unseal = false

# consul cluster attributes
# consul_cluster_name = ""
# consul_cluster_size = 1
# consul_instance_type = ""
# consul_cluster_tag_key = ""

# common attributes
standard_tags = {
    "project-name" = "hc-jb-demo"
    "owner"        = "hc-jb"
    "TTL"          = "6"
}
