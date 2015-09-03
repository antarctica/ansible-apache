# Terraform definition file - this file is used to describe the required infrastructure for this project.

# Variables

variable "digital_ocean_token" {}  # Define using environment variable - e.g. TF_VAR_digital_ocean_token=XXX
variable "ssh_fingerprint" {}      # Define using environment variable - e.g. TF_VAR_ssh_fingerprint=XXX


# Providers

# Digital Ocean provider configuration

# TODO: Add Atlas provider configuration

provider "digitalocean" {
	token = "${var.digital_ocean_token}"
}


# Resources

# TODO: Add Atlas artefact for DigitalOcean droplet image

# 'barc-apache-test-bare' resource

# VM

module "barc-apache-test-bare-droplet" {
  source = "github.com/antarctica/terraform-module-digital-ocean-droplet?ref=v1.1.0"
  hostname = "barc-apache-test-bare"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  image = 13126041  # Update to use Atlas resource
}

# DNS records (public, private and default [which is an APEX record and points to public])

module "barc-apache-test-bare-records" {
  source = "github.com/antarctica/terraform-module-digital-ocean-records?ref=v1.0.2"
  hostname = "barc-apache-test-bare"
  machine_interface_ipv4_public = "${module.barc-apache-test-bare-droplet.ip_v4_address_public}"
  machine_interface_ipv4_private = "${module.barc-apache-test-bare-droplet.ip_v4_address_private}"
}

# 'barc-apache-test-http-only' resource

# VM

module "barc-apache-test-http-only-droplet" {
  source = "github.com/antarctica/terraform-module-digital-ocean-droplet?ref=v1.1.0"
  hostname = "barc-apache-test-http-only"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  image = 13126041  # Update to use Atlas resource
}

# DNS records (public, private and default [which is an APEX record and points to public])

module "barc-apache-test-http-only-records" {
  source = "github.com/antarctica/terraform-module-digital-ocean-records?ref=v1.0.2"
  hostname = "barc-apache-test-http-only"
  machine_interface_ipv4_public = "${module.barc-apache-test-http-only-droplet.ip_v4_address_public}"
  machine_interface_ipv4_private = "${module.barc-apache-test-http-only-droplet.ip_v4_address_private}"
}

# 'barc-apache-test-https-only' resource

# VM

module "barc-apache-test-https-only-droplet" {
  source = "github.com/antarctica/terraform-module-digital-ocean-droplet?ref=v1.1.0"
  hostname = "barc-apache-test-https-only"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  image = 13126041  # Update to use Atlas resource
}

# DNS records (public, private and default [which is an APEX record and points to public])

module "barc-apache-test-https-only-records" {
  source = "github.com/antarctica/terraform-module-digital-ocean-records?ref=v1.0.2"
  hostname = "barc-apache-test-https-only"
  machine_interface_ipv4_public = "${module.barc-apache-test-https-only-droplet.ip_v4_address_public}"
  machine_interface_ipv4_private = "${module.barc-apache-test-https-only-droplet.ip_v4_address_private}"
}

# 'barc-apache-test-http-to-https' resource

# VM

module "barc-apache-test-http-to-https-droplet" {
  source = "github.com/antarctica/terraform-module-digital-ocean-droplet?ref=v1.1.0"
  hostname = "barc-apache-test-http-to-https"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  image = 13126041  # Update to use Atlas resource
}

# DNS records (public, private and default [which is an APEX record and points to public])

module "barc-apache-test-http-to-https-records" {
  source = "github.com/antarctica/terraform-module-digital-ocean-records?ref=v1.0.2"
  hostname = "barc-apache-test-http-to-https"
  machine_interface_ipv4_public = "${module.barc-apache-test-http-to-https-droplet.ip_v4_address_public}"
  machine_interface_ipv4_private = "${module.barc-apache-test-http-to-https-droplet.ip_v4_address_private}"
}

# Provisioning (using a fake resource as provisioners can't be first class objects)

# Note: The "null_resource" is an undocumented feature and should not be relied upon.
# See https://github.com/hashicorp/terraform/issues/580 for more information.

#resource "null_resource" "provisioning" {
#
#    depends_on = ["module.barc-apache-test-http-to-https-records"]
#
#    # This replicates the provisioning steps performed by Vagrant
#    provisioner "local-exec" {
#        command = "ansible-galaxy install https://github.com/antarctica/ansible-prelude,v0.1.2 --roles-path=provisioning/roles_bootstrap  --no-deps --force"
#    }
#    provisioner "local-exec" {
#        command = "ansible-playbook -i provisioning/local provisioning/prelude.yml"
#    }
#    provisioner "local-exec" {
#        command = "ansible-playbook -i provisioning/testing-remote provisioning/bootstrap-digitalocean.yml"
#    }
#}
