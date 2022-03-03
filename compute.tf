#Compute resources

#Instance for web server
resource "openstack_compute_instance_v2" "web_instance" {
  region      = var.region
  count       = lookup(var.role_count, "web", 0)
  name        = "${var.name}-web-${count.index}"
  image_name  = lookup(var.role_image, "web", "unknown")
  flavor_name = lookup(var.role_flavor, "web", "unknown")

  key_pair = "${var.name}"
  security_groups = [
    "default",
    "${var.name}-ssh",
    "${var.name}-web",
  ]

  network {
    name = "${var.name}-network"
  }

  metadata = {
    ssh_user       = lookup(var.role_ssh_user, "web", "unknown")
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

# Instance for Database server
resource "openstack_compute_instance_v2" "db_instance" {
  region      = var.region
  count       = lookup(var.role_count, "db", 0)
  name        = "${var.name}-db-${count.index}"
  image_name  = lookup(var.role_image, "db", "unknown")
  flavor_name = lookup(var.role_flavor, "db", "unknown")

  key_pair = "${var.name}"
  security_groups = [
    "default",
    "${var.name}-ssh",
    "${var.name}-db",
  ]

  network {
    name = "${var.name}-network"
  }

  metadata = {
    ssh_user       = lookup(var.role_ssh_user, "db", "unknown")
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
