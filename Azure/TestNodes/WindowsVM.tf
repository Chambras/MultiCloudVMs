resource "azurerm_public_ip" "winpublicip" {
    name                         = "${var.winVMName}_${var.publicIPName}"
    location                     = "${azurerm_resource_group.genericRG.location}"
    resource_group_name          = "${azurerm_resource_group.genericRG.name}"
    allocation_method            = "${var.publicIPAllocation}"

  tags = "${var.tags}"
}

resource "azurerm_network_interface" "winNI" {
  name                = "${var.winVMName}_${var.networkInterfaceName}"
  location            = "${azurerm_resource_group.genericRG.location}"
  resource_group_name = "${azurerm_resource_group.genericRG.name}"
  network_security_group_id = "${azurerm_network_security_group.genericNSG.id}"

  ip_configuration {
    name                          = "winconfiguration"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.winpublicip.id}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "winVM" {
  name                  = "${var.winVMName}"
  location              = "${azurerm_resource_group.genericRG.location}"
  resource_group_name   = "${azurerm_resource_group.genericRG.name}"
  network_interface_ids = ["${azurerm_network_interface.winNI.id}"]
  vm_size               = "${var.vmSize}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.winVMName}_osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.winVMName}"
    admin_username = "<<USERNAME TO USE>>"
    admin_password = "<<PASSWORD TO USE>>"
  }
  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = true
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine_extension" "iis" {
  name                 = "install-iis"
  resource_group_name  = "${azurerm_resource_group.genericRG.name}"
  location             = "${azurerm_resource_group.genericRG.location}"
  virtual_machine_name = "${azurerm_virtual_machine.winVM.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    { 
      "commandToExecute": "powershell Add-WindowsFeature Web-Asp-Net45;Add-WindowsFeature NET-Framework-45-Core;Add-WindowsFeature Web-Net-Ext45;Add-WindowsFeature Web-ISAPI-Ext;Add-WindowsFeature Web-ISAPI-Filter;Add-WindowsFeature Web-Mgmt-Console;Add-WindowsFeature Web-Scripting-Tools;Add-WindowsFeature Search-Service;Add-WindowsFeature Web-Filtering;Add-WindowsFeature Web-Basic-Auth;Add-WindowsFeature Web-Windows-Auth;Add-WindowsFeature Web-Default-Doc;Add-WindowsFeature Web-Http-Errors;Add-WindowsFeature Web-Static-Content;"
    } 
SETTINGS

tags = "${var.tags}"

}
