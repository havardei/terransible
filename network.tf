#Networking setup

#Router
resource "openstack_networking_router_v2" "router" {
  count               = 1
  name                = "${var.name}-router"
  admin_state_up      = "true"
  external_network_id = "7b4df2ac-be48-44fc-888e-3706f49b86e3"
}

#Network
resource "openstack_networking_network_v2" "network" {
  count          = 1
  name           = "${var.name}-network"
  dns_domain     = null
  admin_state_up = "true"
}

#Subnet
resource "openstack_networking_subnet_v2" "subnet" {
  count           = 1
  name            = "${var.name}-internal-network"
  network_id      = openstack_networking_network_v2.network[count.index].id
  cidr            = "10.0.0.0/24"
  ip_version      = 4
}

#Router interface
resource "openstack_networking_router_interface_v2" "interface" {
  count     = 1
  router_id = openstack_networking_router_v2.router[count.index].id
  subnet_id = openstack_networking_subnet_v2.subnet[count.index].id
}

#Floating ip(s) for webserver(s)
resource "openstack_networking_floatingip_v2" "fipweb" {
  count      = lookup(var.role_count, "web", 0)
  pool       = "ntnu-internal"
}

#Floating ip(s) for dbserver(s)
resource "openstack_networking_floatingip_v2" "fipdb" {
  count       = lookup(var.role_count, "db", 0)
  pool       = "ntnu-internal"
} 
