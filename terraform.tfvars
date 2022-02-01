# Region
region = "NTNU-IT"

# This is needed to access the instance over ssh
allow_ssh_from_v6 = [
  #"2001:700:100:12::7/128",
  #"2001:700:100:118::67/128"
]
allow_ssh_from_v4 = [
  "129.241.0.0/16",
  "10.0.0.0/8"
]

# This is needed to access the instance over http
allow_http_from_v6 = [
  #"2001:700:200::/48",
  #"2001:700:100::/41"
]
allow_http_from_v4 = [
  "129.241.0.0/16",
  "10.0.0.0/8"
]

# This is needed to access the instance over the mysql port
allow_mysql_from_v6 = [
  #"2001:700:100:118::67/128"
]
allow_mysql_from_v4 = [
  #"129.240.118.67/32"
]
