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

#Network setup
resource "openstack_networking_router_v2" "router" {
  count               = 1
  name                = "${var.name}-router"
  admin_state_up      = "true"
  external_network_id = "7b4df2ac-be48-44fc-888e-3706f49b86e3"
}

resource "openstack_networking_network_v2" "network" {
  count          = 1
  name           = "${var.name}-network"
  dns_domain     = null
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  count           = 1
  name            = "${var.name}-internal-network"
  network_id      = openstack_networking_network_v2.network[count.index].id
  cidr            = "10.0.0.0/24"
  ip_version      = 4
}

resource "openstack_networking_router_interface_v2" "interface" {
  count     = 1
  router_id = openstack_networking_router_v2.router[count.index].id
  subnet_id = openstack_networking_subnet_v2.subnet[count.index].id
}
resource "openstack_networking_floatingip_v2" "fipweb" {
  count      = lookup(var.role_count, "web", 0)
  pool       = "ntnu-internal"
}
resource "openstack_networking_floatingip_v2" "fipdb" {
  count       = lookup(var.role_count, "db", 0)
  pool       = "ntnu-internal"
} 

resource "openstack_compute_instance_v2" "web_instance" {
  region      = var.region
  count       = lookup(var.role_count, "web", 0)
  name        = "web-${count.index}"
  image_name  = lookup(var.role_image, "web", "unknown")
  flavor_name = lookup(var.role_flavor, "web", "unknown")

  key_pair = "${var.name}"
  security_groups = [
    "default",
    "${terraform.workspace}-${var.name}-ssh",
    "${terraform.workspace}-${var.name}-web",
  ]

  network {
    name = "${var.name}-network"
  }

  metadata = {
    ssh_user       = lookup(var.role_ssh_user, "web", "unknown")
    prefer_ipv6    = 1
    my_server_role = "web"
  }

  lifecycle {
    ignore_changes = [image_name]
  }

  depends_on = [
    openstack_networking_secgroup_v2.instance_ssh_access,
    openstack_networking_secgroup_v2.instance_web_access,
    openstack_networking_network_v2.network[0]
  ]
}

# Database servers
resource "openstack_compute_instance_v2" "db_instance" {
  region      = var.region
  count       = lookup(var.role_count, "db", 0)
  name        = "db-${count.index}"
  image_name  = lookup(var.role_image, "db", "unknown")
  flavor_name = lookup(var.role_flavor, "db", "unknown")

  key_pair = "${var.name}"
  security_groups = [
    "default",
    "${terraform.workspace}-${var.name}-ssh",
    "${terraform.workspace}-${var.name}-db",
  ]

  network {
    name = "${var.name}-network"
  }

  metadata = {
    ssh_user       = lookup(var.role_ssh_user, "db", "unknown")
    prefer_ipv6    = 1
    python_bin     = "/usr/bin/python3"
    my_server_role = "database"
  }

  lifecycle {
    ignore_changes = [image_name]
  }

  depends_on = [
    openstack_networking_secgroup_v2.instance_ssh_access,
    openstack_networking_secgroup_v2.instance_db_access,
    openstack_networking_network_v2.network[0]
  ]
}

# Volume
resource "openstack_blockstorage_volume_v2" "volume" {
  name = "database"
  size = var.volume_size
}

# Attach volume
resource "openstack_compute_volume_attach_v2" "attach_vol" {
  instance_id = openstack_compute_instance_v2.db_instance[0].id
  volume_id   = openstack_blockstorage_volume_v2.volume.id
}
resource "openstack_compute_floatingip_associate_v2" "associate_fip_web" {
  count			= lookup(var.role_count, "web", 0)
  instance_id           = element(openstack_compute_instance_v2.web_instance.*.id, count.index)
  floating_ip		= openstack_networking_floatingip_v2.fipweb[count.index].address
  wait_until_associated = "false"
}

resource "openstack_compute_floatingip_associate_v2" "associate_fip_db" {
  count			= lookup(var.role_count, "db", 0)
  instance_id           = element(openstack_compute_instance_v2.db_instance.*.id, count.index)
  floating_ip		= openstack_networking_floatingip_v2.fipdb[count.index].address
  wait_until_associated = "false"
}
