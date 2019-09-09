
resource "azurerm_virtual_network" "multicloud" {
  name                = "${var.vnetName}"
  location            = "${azurerm_resource_group.genericRG.location}"
  resource_group_name = "${azurerm_resource_group.genericRG.name}"
  address_space       = ["10.1.0.0/16"]

  tags = "${var.tags}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.genericRG.name}"
  virtual_network_name = "${azurerm_virtual_network.multicloud.name}"
  address_prefix       = "10.1.2.0/24"
}

resource "azurerm_subnet" "public" {
  name                 = "public"
  resource_group_name  = "${azurerm_resource_group.genericRG.name}"
  virtual_network_name = "${azurerm_virtual_network.multicloud.name}"
  address_prefix       = "10.1.4.0/24"
}
