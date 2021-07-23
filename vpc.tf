#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "otf" {
  cidr_block = "10.0.0.0/16"

  tags = tomap(
    { 
    "Name" = "terraform-eks-otf-node"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
  )
}

resource "aws_subnet" "otf" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.otf.id

  tags = tomap(
    {
      "Name" = "terraform-eks-otf-node"
      "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
  )
}

resource "aws_internet_gateway" "otf" {
  vpc_id = aws_vpc.otf.id

  tags = {
    Name = "terraform-eks-otf"
  }
}

resource "aws_route_table" "otf" {
  vpc_id = aws_vpc.otf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.otf.id
  }
}

resource "aws_route_table_association" "otf" {
  count = 2

  subnet_id      = aws_subnet.otf.*.id[count.index]
  route_table_id = aws_route_table.otf.id
}