resource "aws_instance" "conditions" {
  instance_type          = var.environment == "dev" ? "t3.micro" : "t3.medium"
  ami                    = "ami-0055977a6e828a4f4"
  vpc_security_group_ids = [aws_security_group.conditions.id]

  tags = {
    Name = "roboshop-conditions"
  }
}

resource "aws_security_group" "conditions" {
  name        = "conditions"
  description = "Allow TLS inbound traffic and all outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "roboshop-conditions"
  }
}