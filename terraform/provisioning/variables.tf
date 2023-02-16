variable "data_center" { default = "Home" }
variable "cluster" { default = "Cluster-1" }
variable "workload_datastore" { default = "esxi-1-nvme-1" }
variable "compute_pool" { default = "Cluster-1/Resources" }
variable "bigip_hostname" { default = "hostname.domain" }
variable "esxi_host" { default = "ESXIHOSTNAME" }

variable "network_external" { default = "lb_external" }
variable "network_internal" { default = "lb_internal" }
variable "network_management" { default = "management" }
variable "network_ha" { default = "server_cluster" }


variable  "bigip_mgmt_addr" { default = "192.168.10.60/24"}
variable  "bigip_mgmt_gw" { default = "192.168.10.1" }
variable "bigip_root_pwd" {}
variable "bigip_admin_pwd" {}

variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "bigip_filepath" { default = "/path/to/downloads/BIGIP-16.1.3.1-0.0.11.ALL-vmware.ova" }
variable "bigip_url" {}
