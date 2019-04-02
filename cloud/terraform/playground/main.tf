provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "queens" {
  ami                                  = "ami-0b613238381319476"
  instance_type                        = "t3.micro"
  subnet_id                            = "subnet-0256edecad5b2ac00"
  vpc_security_group_ids               = ["${aws_security_group.police.id}"]
  associate_public_ip_address          = "true"

  user_data                            = <<-EOF
                                       #cloud-boothook
                                       #!/bin/bash
                                       echo `whoami` > /tmp/hotdog
                                       sudo yum install httpd -y 
                                       sudo mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf./welcome.conf.old 
                                       sudo echo "papiFresco be the illest" > /var/www/html/index.html
                                       sudo service httpd start
                                       EOF


  tags {
   Name = "queens"
 }
}

resource "aws_security_group" "police" {
  name = "nypd"
  vpc_id = "vpc-0f5289f2ba94e567a"
  ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
 }
  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
 }
}

output "public_ip" {
    value        ="${aws_instance.queens.public_ip}"
 }
