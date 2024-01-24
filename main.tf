provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2_instance" {
  count         = 3
  ami           = "ami-0a346c29399cd4934" 
  instance_type = "t2.micro"
  key_name      = "ssh"
  subnet_id     = "subnet-01e2cf6dd9b12959c" #  subnet ID
  associate_public_ip_address = true

  tags = {
    Name = "ec2_mini_project"
  }
}

resource "aws_elb" "web_elb" {
  name                        = "web-elb"
  subnets                      = ["subnet-01e2cf6dd9b12959c"] #  subnets IDs
  security_groups             = ["sg-0be5aa40603b3d4fd"]    #  security group ID
  instances                   = aws_instance.ec2_instance[*].id 
  cross_zone_load_balancing   = true
  internal                    = false
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 400
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_route53_record" "terraform_test_record" {
  zone_id = "Z09263843GZT6S81SLGEV"
  name    = "Mini-ec2_mini_project.com"
  type    = "A"
  ttl     = "300"
  records = [aws_elb.web_elb.dns_name]
}

output "my_console_output" {
  value = "aws_instance.ec2_instance.public_ip"
}

output "aws_elb" {
  value = "aws_elb.web_elb.public_ip"
}