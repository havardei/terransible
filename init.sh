#!/bin/bash
TERRAFORM_STATE_ROOT=$(pwd)
terraform init
terraform apply --auto-approve
sleep 30
ansible-playbook -i inventory app.yml
