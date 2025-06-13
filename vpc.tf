
# terraform/vpc.tf - VPC Resources (Optional)
resource "aws_vpc" "mlops_vpc" {
  count                = var.enable_vpc ? 1 : 0
  cidr_block          = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "private_subnet" {
  count             = var.enable_vpc ? 2 : 0
  vpc_id            = aws_vpc.mlops_vpc[0].id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "public_subnet" {
  count                   = var.enable_vpc ? 2 : 0
  vpc_id                  = aws_vpc.mlops_vpc[0].id
  cidr_block              = "10.0.${count.index + 10}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
  })
}

resource "aws_internet_gateway" "mlops_igw" {
  count  = var.enable_vpc ? 1 : 0
  vpc_id = aws_vpc.mlops_vpc[0].id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_route_table" "public_rt" {
  count  = var.enable_vpc ? 1 : 0
  vpc_id = aws_vpc.mlops_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mlops_igw[0].id
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route_table_association" "public_rta" {
  count          = var.enable_vpc ? 2 : 0
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[0].id
}

resource "aws_security_group" "sagemaker_sg" {
  count       = var.enable_vpc ? 1 : 0
  name        = "${local.name_prefix}-sagemaker-sg"
  description = "Security group for SageMaker resources"
  vpc_id      = aws_vpc.mlops_vpc[0].id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.mlops_vpc[0].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-sagemaker-sg"
  })
}

data "aws_availability_zones" "available" {
  state = "available"
}
