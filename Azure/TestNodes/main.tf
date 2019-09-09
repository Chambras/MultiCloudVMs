terraform {
  backend "remote" {
    organization = "<<YOUR TERRAFORM ENTERPRISE ORGANIZATION>>"

    workspaces {
      name = "<<ORGANIZATION>>"
    }
  }
}

provider "azurerm" {
  version = "=1.33.1"
}
resource "azurerm_resource_group" "genericRG" {
  name = "${var.rgName}"
  location = "${var.location}"
  tags = "${var.tags}"
}
