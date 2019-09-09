
resource "azurerm_public_ip" "linuxpublicip" {
    name                         = "${var.linuxVMName}_${var.publicIPName}"
    location                     = "${azurerm_resource_group.genericRG.location}"
    resource_group_name          = "${azurerm_resource_group.genericRG.name}"
    allocation_method            = "Static"

  tags = "${var.tags}"
}

resource "azurerm_network_interface" "linuxNI" {
  name                = "${var.linuxVMName}_${var.networkInterfaceName}"
  location            = "${azurerm_resource_group.genericRG.location}"
  resource_group_name = "${azurerm_resource_group.genericRG.name}"
  network_security_group_id = "${azurerm_network_security_group.genericNSG.id}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.linuxpublicip.id}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "web-server" {
  name                  = "${var.linuxVMName}"
  location              = "${azurerm_resource_group.genericRG.location}"
  resource_group_name   = "${azurerm_resource_group.genericRG.name}"
  network_interface_ids = ["${azurerm_network_interface.linuxNI.id}"]
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
    name              = "${var.linuxVMName}_osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.linuxVMName}"
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
      key_data = <<SSH KEY TO USE>>
    }
  }
  tags = "${var.tags}"
}
