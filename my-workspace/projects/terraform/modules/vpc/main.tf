###############################################################################
# Default VPC
###############################################################################

resource "aws_default_vpc" "default" {
  tags = {
    Name = "default-vpc"
  }
}

###############################################################################
# Default Subnets (one per AZ in us-east-1)
###############################################################################

resource "aws_default_subnet" "us_east_1a" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "default-subnet-us-east-1a"
  }
}

resource "aws_default_subnet" "us_east_1b" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "default-subnet-us-east-1b"
  }
}

resource "aws_default_subnet" "us_east_1c" {
  availability_zone = "us-east-1c"

  tags = {
    Name = "default-subnet-us-east-1c"
  }
}

resource "aws_default_subnet" "us_east_1d" {
  availability_zone = "us-east-1d"

  tags = {
    Name = "default-subnet-us-east-1d"
  }
}

resource "aws_default_subnet" "us_east_1e" {
  availability_zone = "us-east-1e"

  tags = {
    Name = "default-subnet-us-east-1e"
  }
}

resource "aws_default_subnet" "us_east_1f" {
  availability_zone = "us-east-1f"

  tags = {
    Name = "default-subnet-us-east-1f"
  }
}

###############################################################################
# Internet Gateway (managed by AWS for default VPC, imported as data or resource)
###############################################################################

resource "aws_internet_gateway" "default" {
  vpc_id = aws_default_vpc.default.id

  tags = {
    Name = "default-igw"
  }
}

###############################################################################
# Default Route Table
###############################################################################

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_default_vpc.default.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "default-rtb"
  }
}

###############################################################################
# Default Security Group
###############################################################################

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  # TODO: Import actual ingress/egress rules
  # After import, run `terraform plan` to see current rules and codify them here.

  tags = {
    Name = "default"
  }
}

###############################################################################
# sg_velintra
###############################################################################

resource "aws_security_group" "sg_velintra" {
  name        = "sg_velintra"
  description = "Security group for velintraOS instance"
  vpc_id      = aws_default_vpc.default.id

  # TODO: Import actual ingress rules
  # ingress {
  #   from_port   = ...
  #   to_port     = ...
  #   protocol    = "tcp"
  #   cidr_blocks = [...]
  # }

  # TODO: Import actual egress rules
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "sg_velintra"
  }
}

###############################################################################
# t16o_v1_services_sg
###############################################################################

resource "aws_security_group" "t16o_v1_services_sg" {
  name        = "t16o_v1_services_sg"
  description = "Security group for t16o v1 services"
  vpc_id      = aws_default_vpc.default.id

  # TODO: Import actual ingress rules
  # ingress {
  #   from_port   = ...
  #   to_port     = ...
  #   protocol    = "tcp"
  #   cidr_blocks = [...]
  # }

  # TODO: Import actual egress rules
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "t16o_v1_services_sg"
  }
}

###############################################################################
# launch-wizard-2
###############################################################################

resource "aws_security_group" "launch_wizard_2" {
  name        = "launch-wizard-2"
  description = "launch-wizard-2 created by EC2 launch wizard"
  vpc_id      = aws_default_vpc.default.id

  # TODO: Import actual ingress rules
  # ingress {
  #   from_port   = ...
  #   to_port     = ...
  #   protocol    = "tcp"
  #   cidr_blocks = [...]
  # }

  # TODO: Import actual egress rules
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "launch-wizard-2"
  }
}

###############################################################################
# launch-wizard-1
###############################################################################

resource "aws_security_group" "launch_wizard_1" {
  name        = "launch-wizard-1"
  description = "launch-wizard-1 created by EC2 launch wizard"
  vpc_id      = aws_default_vpc.default.id

  # TODO: Import actual ingress rules
  # ingress {
  #   from_port   = ...
  #   to_port     = ...
  #   protocol    = "tcp"
  #   cidr_blocks = [...]
  # }

  # TODO: Import actual egress rules
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "launch-wizard-1"
  }
}
