# Output Values:

# Domain
output "domainname" {
  value = "${var.route53_subdomain}.${var.route53_domain}"
}

# Rancher Instance
output "rancher-instance-private-ip" {
  value = ["${aws_instance.rancher.private_ip}"]
}
output "rancher-instance-public-ip" {
  value = ["${aws_eip.rancher-eip.public_ip}"]
}
output "rancher-instance-name" {
  value = ["${aws_route53_record.rancher.name}"]
}
output "rancher-rke-instance-name" {
  value = ["${aws_route53_record.rancher-rke.name}"]
}

# SUSE AI GPU Node Instance
output "suseai-instance-private-ip" {
  value = ["${aws_instance.gpu-node.private_ip}"]
}
output "suseai-instance-public-ip" {
  value = ["${aws_eip.gpu-node-eip.public_ip}"]
}
output "suseai-instance-name" {
  value = ["${aws_route53_record.suseai.name}"]
}
output "suseai-rke-instance-name" {
  value = ["${aws_route53_record.suseai-rke.name}"]
}

