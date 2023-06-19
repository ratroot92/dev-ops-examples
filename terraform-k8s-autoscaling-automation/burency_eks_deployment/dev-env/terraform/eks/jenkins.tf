terraform {
  backend "s3" {
    bucket = "burency-dev-jenkins-bucket"
    region = "us-east-1"
    key    = "jenkins-server/terraform.tfstate"
  }
}




resource "aws_default_route_table" "aws_default_route_table" {
  default_route_table_id = aws_vpc.aws_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
  }
  tags = {
    Name = "${var.env_prefix}-aws_default_route_table"
  }
}

resource "aws_default_security_group" "aws_default_security_group" {
  vpc_id = aws_vpc.aws_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env_prefix}-aws_default_security_group"
  }
}


data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins_aws_instance" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = "t2.small"
  key_name                    = "Burency"
  subnet_id                   = aws_subnet.aws_subnet_public_us_east_1a.id
  vpc_security_group_ids      = [aws_default_security_group.aws_default_security_group.id]
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  user_data                   = file("jenkins-server-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}

output "ec2_public_ip" {
  value = aws_instance.jenkins_aws_instance.public_ip
}
