resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("${var.private_key_path}.pub")
}

resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "flask_server" {
  ami           = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04
  instance_type = "t2.small"
  key_name      = var.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "flask-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_ecr_repository" "flask_repo" {
  name = "flask-app"
}
