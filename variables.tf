# Variables
variable "region" {
  default = "NTNU-IT"
}

variable "name" {
  default = "didnt-read-docs"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "metadata" {
  type    = list(string)
  default = []
}

variable "allow_ssh_from_v4" {
  type    = list(string)
  default = []
}

variable "allow_http_from_v4" {
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
    "db"  = "m1.small"
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
