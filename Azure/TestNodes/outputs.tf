output "generic_RG" {
  value = "${azurerm_resource_group.genericRG.name}"
}

output "linux_public_ip_address" {
  value = "${azurerm_public_ip.linuxpublicip.ip_address}"
}

output "linux_private_ip_address" {
  value = "${azurerm_network_interface.linuxNI.private_ip_address}"
}

output "win_public_ip_address" {
  value = "${azurerm_public_ip.winpublicip.ip_address}"
}

output "win_private_ip_address" {
  value = "${azurerm_network_interface.winNI.private_ip_address}"
}

output "vNetID" {
  value = "${azurerm_virtual_network.multicloud.id}"
}

output "internal_subnet" {
  value = "${azurerm_subnet.internal.id}"
}

output "public_subnet" {
  value = "${azurerm_subnet.public.id}"
}
