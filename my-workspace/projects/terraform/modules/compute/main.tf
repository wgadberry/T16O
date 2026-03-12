###############################################################################
# Key Pairs
###############################################################################

resource "aws_key_pair" "t160_v1_services" {
  key_name   = "t160_v1_services"
  public_key = "PLACEHOLDER - replace with actual public key material"
  # TODO: Replace public_key with actual key after import
}

resource "aws_key_pair" "kp_node_win_svc_16o" {
  key_name   = "kp-nodeWinSvc16o"
  public_key = "PLACEHOLDER - replace with actual public key material"
  # TODO: Replace public_key with actual key after import
}

resource "aws_key_pair" "kp_velintra" {
  key_name   = "kp-velintra"
  public_key = "PLACEHOLDER - replace with actual public key material"
  # TODO: Replace public_key with actual key after import
}

resource "aws_key_pair" "t160_core_winsrv_01" {
  key_name   = "t160_core_winsrv_01"
  public_key = "PLACEHOLDER - replace with actual public key material"
  # TODO: Replace public_key with actual key after import
}

resource "aws_key_pair" "node_win_svc_16o" {
  key_name   = "node-win-svc-16o"
  public_key = "PLACEHOLDER - replace with actual public key material"
  # TODO: Replace public_key with actual key after import
}

resource "aws_key_pair" "t16o_core_lnxsrv_01" {
  key_name   = "t16o_core_lnxsrv_01"
  public_key = "PLACEHOLDER - replace with actual public key material"
  # TODO: Replace public_key with actual key after import
}

###############################################################################
# EC2 Instance: velintraOS
###############################################################################

resource "aws_instance" "velintra_os" {
  ami           = "ami-00000000000000000" # TODO: Replace with actual AMI after import
  instance_type = "t2.large"
  key_name      = aws_key_pair.kp_velintra.key_name
  subnet_id     = var.subnet_id # TODO: Verify actual subnet after import

  vpc_security_group_ids = [
    var.sg_velintra_id,
  ]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "velintraOS"
  }

  lifecycle {
    prevent_destroy = true
  }
}

###############################################################################
# EC2 Instance: svcs.the16oracles.io
###############################################################################

resource "aws_instance" "svcs_the16oracles_io" {
  ami           = "ami-00000000000000000" # TODO: Replace with actual AMI after import
  instance_type = "t3.large"
  key_name      = aws_key_pair.t160_v1_services.key_name
  subnet_id     = var.subnet_id # TODO: Verify actual subnet after import

  vpc_security_group_ids = [
    var.sg_t16o_v1_services_id,
  ]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "svcs.the16oracles.io"
  }

  lifecycle {
    prevent_destroy = true
  }
}

###############################################################################
# Elastic IP for svcs.the16oracles.io
###############################################################################

resource "aws_eip" "svcs_the16oracles_io" {
  domain = "vpc"

  tags = {
    Name = "svcs.the16oracles.io-eip"
  }
}

resource "aws_eip_association" "svcs_the16oracles_io" {
  instance_id   = aws_instance.svcs_the16oracles_io.id
  allocation_id = aws_eip.svcs_the16oracles_io.id
}

###############################################################################
# EBS Volumes (30GB gp3 each)
###############################################################################

resource "aws_ebs_volume" "velintra_os_data" {
  availability_zone = var.availability_zone # TODO: Verify AZ after import
  size              = 30
  type              = "gp3"

  tags = {
    Name = "velintraOS-data"
  }
}

resource "aws_ebs_volume" "svcs_the16oracles_io_data" {
  availability_zone = var.availability_zone # TODO: Verify AZ after import
  size              = 30
  type              = "gp3"

  tags = {
    Name = "svcs.the16oracles.io-data"
  }
}
