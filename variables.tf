# Variables
variable "region" {
}

variable "name" {
  default = "terransibletest"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "network" {
  default = ""
}

variable "volume_size" {
  default = 20
}

variable "metadata" {
  type    = list(string)
  default = []
}

# Security group defaults
variable "allow_ssh_from_v6" {
  type    = list(string)
  default = []
}

variable "allow_ssh_from_v4" {
  type    = list(string)
  default = []
}

variable "allow_http_from_v6" {
  type    = list(string)
  default = []
}

variable "allow_http_from_v4" {
  type    = list(string)
  default = []
}

variable "allow_mysql_from_v6" {
  type    = list(string)
  default = []
}

variable "allow_mysql_from_v4" {
  type    = list(string)
  default = []
}

# Mapping between role and image
variable "role_image" {
  type = map(string)
  default = {
    "web" = "Ubuntu Server 20.04 (Focal) amd64 20200424"
    "db"  = "Ubuntu Server 20.04 (Focal) amd64 20200424"
  }
}

# Mapping between role and flavor
variable "role_flavor" {
  type = map(string)
  default = {
    "web" = "m1.small"
    "db"  = "m1.medium"
  }
}

# Mapping between role and number of instances (count)
variable "role_count" {
  type = map(string)
  default = {
    "web" = 1
    "db"  = 1
  }
}

# Mapping between role and SSH user
variable "role_ssh_user" {
  type = map(string)
  default = {
    "web" = "ubuntu"
    "db"  = "ubuntu"
  }
}
