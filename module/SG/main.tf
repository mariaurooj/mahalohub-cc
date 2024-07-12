resource "aws_security_group" "allow_tls" {
  vpc_id = "vpc-0d93879d3d16ed774"
  ingress {
    from_port   = var.sg.port1
    to_port     = var.sg.port1
    protocol    = var.sg.ingress1.ingress1_protocol
    cidr_blocks = [var.sg.ingress1.ingress1_cidr_blocks]
  }
  ingress {
    from_port   = var.sg.port2
    to_port     = var.sg.port2
    protocol    = var.sg.ingress1.ingress1_protocol
    cidr_blocks = [var.sg.ingress1.ingress1_cidr_blocks]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = [var.sg.ingress1.ingress1_cidr_blocks]
  }
  ingress {
    from_port   = var.sg.port3
    to_port     = var.sg.port3
    protocol    = var.sg.ingress1.ingress1_protocol
    cidr_blocks = [var.sg.ingress1.ingress1_cidr_blocks]
  }
  ingress {
    from_port   = var.sg.ingress1.port
    to_port     = var.sg.ingress1.port
    protocol    = var.sg.ingress1.ingress1_protocol
    cidr_blocks = [var.sg.ingress1.ingress1_cidr_blocks]
  }
  ingress {
    from_port   = var.sg.ingress2.port
    to_port     = var.sg.ingress2.port
    protocol    = var.sg.ingress2.ingress2_protocol
    cidr_blocks = [var.sg.ingress2.ingress2_cidr_blocks]
  }
  ingress {
    from_port   = var.sg.port
    to_port     = var.sg.port
    protocol    = var.sg.ingress2.ingress2_protocol
    cidr_blocks = [var.sg.ingress2.ingress2_cidr_blocks]
  }
  egress {
    from_port   = var.sg.egress.port
    to_port     = var.sg.egress.port
    protocol    = var.sg.egress.egress1_protocol
    cidr_blocks = [var.sg.egress.egress1_cidr_blocks]
  }

  tags = {
    Name = "${var.environment}-${var.prefix}-sg"
  }
}