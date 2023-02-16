provider "vsphere" {
  user			= var.vsphere_user
  password		= var.vsphere_password
  vsphere_server	= var.vsphere_server
}

data "vsphere_datacenter" "dc" {
  name			= var.data_center
}

data "vsphere_compute_cluster" "cluster" {
  name			= var.cluster
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name			= var.workload_datastore
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name			= var.compute_pool
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name			= var.esxi_host
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net_external" {
  name			= var.network_external
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net_internal" {
  name                  = var.network_internal
  datacenter_id         = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net_management" {
  name                  = var.network_management
  datacenter_id         = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net_ha" {
  name                  = var.network_ha
  datacenter_id         = data.vsphere_datacenter.dc.id
}


data "vsphere_ovf_vm_template" "ovf" {
  name			= "bigip_ve"
  resource_pool_id      = data.vsphere_resource_pool.pool.id
  datastore_id          = data.vsphere_datastore.datastore.id
  host_system_id        = data.vsphere_host.host.id

# Not using remote URL
# remote_ovf_url = var.bigip_url

  local_ovf_path= var.bigip_filepath
  deployment_option = "octalcpu"

  ovf_network_map = {
    "Management" = data.vsphere_network.net_management.id
    "Internal" = data.vsphere_network.net_internal.id
    "External" = data.vsphere_network.net_external.id
    "HA" = data.vsphere_network.net_ha.id

  }


}


resource "vsphere_virtual_machine" "bigip_ve" {
  datacenter_id         = data.vsphere_datacenter.dc.id

  name 			= var.bigip_hostname

  num_cpus		= data.vsphere_ovf_vm_template.ovf.num_cpus
  memory		= data.vsphere_ovf_vm_template.ovf.memory
  resource_pool_id      = data.vsphere_ovf_vm_template.ovf.resource_pool_id
  datastore_id          = data.vsphere_datastore.datastore.id
  host_system_id	= data.vsphere_host.host.id

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout = 0

  ovf_deploy {
    #remote_ovf_url = data.vsphere_ovf_vm_template.ovf.remote_ovf_url. <--- Option to use remote URL
    local_ovf_path = data.vsphere_ovf_vm_template.ovf.local_ovf_path
    deployment_option = data.vsphere_ovf_vm_template.ovf.deployment_option
    allow_unverified_ssl_cert = true
    ovf_network_map = data.vsphere_ovf_vm_template.ovf.ovf_network_map

    ip_protocol = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
  }

  scsi_type = data.vsphere_ovf_vm_template.ovf.scsi_type

# Need to set the network interfaces again inside the VM object, otherwise Terraform
# will reconfigure the VM and remove the adapters.
# While there is an option for dynamic content, the lookup returns an alphabetically sorted array so the networks
# dont match up to the correct adapters.
# The way TF works, the interfaces will be set in the order they appear in the declaration.


  network_interface {
    network_id  = data.vsphere_network.net_management.id
  }

  network_interface {
    network_id  = data.vsphere_network.net_internal.id
  }

  network_interface {
    network_id  = data.vsphere_network.net_external.id
  }

  network_interface {
    network_id  = data.vsphere_network.net_ha.id
  }

#  dynamic "network_interface" {
#    for_each = data.vsphere_ovf_vm_template.ovf.ovf_network_map
#    content {
#      network_id = network_interface.value
#    }
#
#  }

  vapp {
    properties = {
      "net.mgmt.addr"=var.bigip_mgmt_addr,
      "net.mgmt.gw" = var.bigip_mgmt_gw,
      "user.root.pwd" = var.bigip_root_pwd,
      "user.admin.pwd" = var.bigip_admin_pwd
    }

  }

}
