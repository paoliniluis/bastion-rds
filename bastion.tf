resource "aws_instance" "bastion_host" {
    ami = data.aws_ami.ubuntu_latest_LTS_amd64.image_id
    instance_type = "t3a.nano"
    key_name = aws_key_pair.generated_key.key_name
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]
    associate_public_ip_address = true
    tags = {
        Name = "bastion_host"
    } 
}

# terraform output -raw private_key

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "private_key"
  public_key = tls_private_key.example.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

output "bastion_public_ip" {
    value = aws_instance.bastion_host.public_ip
}