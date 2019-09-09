variable "location" {
  type = "string"
  default = "eastus"
  description = "Location where the resoruces are going to be created."
}

variable "rgName" {
    type = "string"
    default = "MultiCloudTestNodesRG"
    description = "Resource Group Name."
}

variable "vnetName" {
    type = "string"
    default = "multi-cloud"
    description = "VNet Name."
}

variable "tags" {
  type = "map"
  default = {
    "Environment" = "Dev"
    "Project" = "MultiCloud-Sample"
    "BillingCode" = "Internal"
  }
}

variable "prefix" {
  default = "dev"
}

variable "suffix" {
  default = "demo"
}

## compute variables
variable "winVMName" {
  type = "string"
  default = "WinServer"
  description = "Default Windows VM server name."
}

variable "linuxVMName" {
  type = "string"
  default = "MainLinuxServer"
  description = "Default Linux VM server name."
}

variable "vmSize" {
  type = "string"
  default = "Standard_DS2_v2"
  description = "Default VM size."
}

variable "publicIPName" {
  type = "string"
  default = "PublicIP"
  description = "Default Public IP name."
}

variable "publicIPAllocation" {
  type = "string"
  default = "Static"
  description = "Default Public IP allocation. Could be Static or Dynamic."
}

variable "networkInterfaceName" {
  type = "string"
  default = "NIC"
  description = "Default Windows Network Interface Name."
}

## Security variables
variable "sgName" {
  type = "string"
  default = "default_RDPSSH_SG"
  description = "Default Security Group Name to be applied by default to VMs and subnets."
}

variable "sourceIPs" {
  type = "list"
  default = ["173.66.39.236"]
  description = "Public IPs to allow inboud communications."
}
