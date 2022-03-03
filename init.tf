# Define required providers
terraform {
  required_version = ">= 0.13.7"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {}

# SSH key
resource "openstack_compute_keypair_v2" "keypair" {
  region     = var.region
  name       = "${var.name}"
  public_key = file(var.ssh_public_key)
}