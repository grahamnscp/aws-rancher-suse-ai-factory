# elastic ips

# Associate Elastic IPs to Instances
resource "aws_eip" "rancher-eip" {

  instance = "${aws_instance.rancher.id}"
  tags = {
    Name = "${var.prefix}-rancher"
  }
  depends_on = [aws_instance.rancher]
}

# SUSE AI GPU INstance
resource "aws_eip" "gpu-node-eip" {

  instance = "${aws_instance.gpu-node.id}"
  tags = {
    Name = "${var.prefix}-suseai"
  }
  depends_on = [aws_instance.gpu-node]
}

