# Route53 DNS entries for instances

# rancher node
resource "aws_route53_record" "rancher" {
  zone_id = "${var.route53_zone_id}"
  name = "rancher.${var.route53_subdomain}.${var.route53_domain}"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.rancher-eip.public_ip}"]
}

# rke cname
resource "aws_route53_record" "rancher-rke" {
  zone_id = "${var.route53_zone_id}"
  name = "rancher-rke.${var.route53_subdomain}.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_route53_record.rancher.name}"]
}

# suseai node
resource "aws_route53_record" "suseai" {
  zone_id = "${var.route53_zone_id}"
  name = "suseai.${var.route53_subdomain}.${var.route53_domain}"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.gpu-node-eip.public_ip}"]
}

# rke cname
resource "aws_route53_record" "suseai-rke" {
  zone_id = "${var.route53_zone_id}"
  name = "suseai-rke.${var.route53_subdomain}.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_route53_record.suseai.name}"]
}

# ai factory all cnames
resource "aws_route53_record" "suseai-ollama" {
  zone_id = "${var.route53_zone_id}"
  name = "ollama.${var.route53_subdomain}.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_route53_record.suseai.name}"]
}
resource "aws_route53_record" "suseai-openwebui" {
  zone_id = "${var.route53_zone_id}"
  name = "owui.${var.route53_subdomain}.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_route53_record.suseai.name}"]
}
resource "aws_route53_record" "suseai-vllm" {
  zone_id = "${var.route53_zone_id}"
  name = "vllm.${var.route53_subdomain}.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_route53_record.suseai.name}"]
}
resource "aws_route53_record" "suseai-litellm" {
  zone_id = "${var.route53_zone_id}"
  name = "litellm.${var.route53_subdomain}.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_route53_record.suseai.name}"]
}
resource "aws_route53_record" "suseai-kubeflow" {
  zone_id = "${var.route53_zone_id}"
  name = "kubeflow.${var.route53_subdomain}.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_route53_record.suseai.name}"]
}
