resource "aws_instance" "t16o_services" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.t16o_services.id]

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "t16o_v1_services"
  }
}

resource "aws_eip" "t16o_services" {
  domain = "vpc"

  tags = {
    Name = "t16o_v1_services_eip"
  }
}

resource "aws_eip_association" "t16o_services" {
  instance_id   = aws_instance.t16o_services.id
  allocation_id = aws_eip.t16o_services.id
}
