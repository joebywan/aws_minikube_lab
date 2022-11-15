# <---- Security Group -----> #
resource "aws_security_group" "security_group" {
  name   = "${var.naming_prefix}-security-group"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.security_group_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    description = "Allow All traffic out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}