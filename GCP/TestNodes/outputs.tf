output "public_ip_address" {
  value = "${google_compute_instance.testserver1.network_interface.0.access_config.0.nat_ip}"
}

output "NetworkName" {
  value = "${google_compute_network.multicloud.name}"
}
