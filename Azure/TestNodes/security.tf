
resource "azurerm_network_security_group" "genericNSG" {
  name                = "${var.suffix}_${var.sgName}"
  location            = "${azurerm_resource_group.genericRG.location}"
  resource_group_name = "${azurerm_resource_group.genericRG.name}"

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes      = "${var.sourceIPs}"
    # source_address_prefix      = "${var.sourceIP}"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = "${var.sourceIPs}"
    # source_address_prefix      = "${var.sourceIP}"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = "${var.tags}"
}
