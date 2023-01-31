resource "aws_vpc" "main_vpc" {
    cidr_block = "192.168.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "main_vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "192.168.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "public_subnet"
    }
}

resource "aws_subnet" "private_subnet-1a" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "192.168.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false
    tags = {
        Name = "private_subnet-1a"
    }
}

resource "aws_subnet" "private_subnet-1b" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "192.168.3.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false
    tags = {
        Name = "private_subnet-1b"
    }
}

resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "main_igw"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }
    tags = {
        Name = "public_route_table"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "private_route_table"
    }
}

resource "aws_route_table_association" "public_route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association-1a" {
    subnet_id = aws_subnet.private_subnet-1a.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association-1b" {
    subnet_id = aws_subnet.private_subnet-1b.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "bastion_sg" {
    name = "bastion_sg"
    description = "bastion_sg"
    vpc_id = aws_vpc.main_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = [aws_subnet.private_subnet-1a.cidr_block, aws_subnet.private_subnet-1b.cidr_block]
    }
}

resource "aws_security_group" "rds_sg" {
    name = "rds_sg"
    description = "rds_sg"
    vpc_id = aws_vpc.main_vpc.id
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = ["192.168.0.0/16"]
    }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
    name = "rds_subnet_group"
    subnet_ids = [aws_subnet.private_subnet-1a.id, aws_subnet.private_subnet-1b.id]
}