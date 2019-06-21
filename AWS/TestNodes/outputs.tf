output "VPC-ID" {
  value = "${aws_vpc.multicloud.id}"
}

output "internal_subnet_id" {
  value = "${aws_subnet.internal.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}

output "SG-ID" {
  value = "${aws_security_group.allow-ssh-http.id}"
}


output "public_ip_address" {
  value       = "${aws_instance.web-server.public_ip}"
}