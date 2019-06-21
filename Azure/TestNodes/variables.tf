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

variable "saKind" {
  type ="string"
  default = "StorageV2"
  description = "Defines the Kind of account. Valid options are Storage, StorageV2 and BlobStorage."
}

variable "saTier" {
  type = "string"
  default = "Standard"
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium."
}

variable "saReplicationType" {
  type = "string"
  default = "GRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS and ZRS."
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
