# bigip-vsphere

## Overview

Terraform plan to deploy a Big-IP OVF into an on-premises VMware environment. 


## Usage

* Modify the `terraform.tfvars` with your endpoint credentials
* Modify `variables.tf` with relevant info

run `terraform apply`





## Notes:

The injection of management IP address, gateway, admin/root password is dependent on having an ovf that accepts the following properties at deployment time:
  * net.mgmt.addr
  * net.mgmt.gw
  * user.root.pwd
  * user.admin.pwd
  
These properties are not there by default. Follow this [DevCentral article](https://community.f5.com/t5/technical-articles/ve-on-vmware-part-1-custom-properties/ta-p/286118) for guidance on adding them with the ovf tool.
