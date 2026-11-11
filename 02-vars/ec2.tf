
resource "aws_instance" "example" {
  ami           = var.ami-id
  instance_type = var.itype
  vpc_security_group_ids = [aws_security_group.mongodb.id] 

  tags = {
    Name = "mongodb practice"
  }
}
resource "aws_security_group" "mongodb" {
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
    manasu="goppadi"
  }
}