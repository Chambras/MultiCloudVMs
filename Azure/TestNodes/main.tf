terraform {
  backend "remote" {
    organization = "<<YOUR TERRAFORM ENTERPRISE ORGANIZATION>>"

    workspaces {
      name = "<<ORGANIZATION>>"
    }
  }
}

provider "azurerm" {
  version = "=1.30.1"
}
resource "azurerm_resource_group" "genericRG" {
  name = "${var.rgName}"
  location = "${var.location}"
  tags = "${var.tags}"
}

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

resource "azurerm_network_security_group" "allow-ssh-http" {
  name                = "multicloud-allow-ssh-http"
  location            = "${azurerm_resource_group.genericRG.location}"
  resource_group_name = "${azurerm_resource_group.genericRG.name}"

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
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
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = "${var.tags}"
}

resource "azurerm_public_ip" "testNodePublicIP" {
    name                         = "testNodePublicIP"
    location                     = "${azurerm_resource_group.genericRG.location}"
    resource_group_name          = "${azurerm_resource_group.genericRG.name}"
    allocation_method            = "Static"

  tags = "${var.tags}"
}

resource "azurerm_network_interface" "testNodeNIC" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.genericRG.location}"
  resource_group_name = "${azurerm_resource_group.genericRG.name}"
  network_security_group_id = "${azurerm_network_security_group.allow-ssh-http.id}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.testNodePublicIP.id}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "web-server" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.genericRG.location}"
  resource_group_name   = "${azurerm_resource_group.genericRG.name}"
  network_interface_ids = ["${azurerm_network_interface.testNodeNIC.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7-CI"
    version   = "latest"
  }
  storage_os_disk {
    name              = "web-serverosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "web-server-1"
    admin_username = "multicloud"
    custom_data = <<-EOF
    #cloud-config
    package_upgrade: true
    packages:
      - httpd
    write_files:
      - content: <!doctype html><html><body><h1>Hello MultiCloud 2019 from Azure!</h1></body></html>
        path: /var/www/html/index.html
    runcmd:
      - [ systemctl, enable, httpd.service ]
      - [ systemctl, start, httpd.service ]
    EOF

  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/multicloud/.ssh/authorized_keys"
      key_data = "<<SSH KEY TO USE>>"
    }
  }
  tags = "${var.tags}"
}
