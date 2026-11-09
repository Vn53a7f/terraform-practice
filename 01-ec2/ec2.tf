data "aws_ami" "selected" {
  filter {
    name   = "image-id"
    values = ["ami-0055977a6e828a4f4"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

/*resource "aws_instance" "example" {
  ami           = data.aws_ami.selected.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mongodb.id] 

  tags = {
    Name = "mongodb practice"
  }
}*/
/*resource "aws_security_group" "mongodb" {
  name        = "mongodb"
  description = "Allow TLS inbound traffic and all outbound traffic"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-roboshop-webbbbbbbbbbbb"
  }
}*/