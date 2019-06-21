output "generic_RG" {
  value = "${azurerm_resource_group.genericRG.name}"
}

output "public_ip_address" {
  value = "${azurerm_public_ip.testNodePublicIP.ip_address}"
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
