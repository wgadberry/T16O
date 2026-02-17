resource "aws_security_group" "t16o_services" {
  name        = "t16o_v1_services_sg"
  description = "T16O services - SSH, Gateway API, RabbitMQ, MySQL"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Gateway API
  ingress {
    description = "Gateway API"
    from_port   = 5100
    to_port     = 5100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RabbitMQ Management UI
  ingress {
    description = "RabbitMQ Management"
    from_port   = 15692
    to_port     = 15692
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # MySQL
  ingress {
    description = "MySQL"
    from_port   = 3397
    to_port     = 3397
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # All outbound (workers need Solscan, Chainstack, GitHub APIs)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "t16o_v1_services_sg"
  }
}
