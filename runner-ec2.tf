resource "aws_instance" "github_runner" {
  ami           = "ami-0c101f26f147fa7fd" # Ubuntu 22.04 in us-east-1
  instance_type = "t2.medium"
  subnet_id     = module.vpc.public_subnets[0]  # Put it in public subnet for now
  key_name      = "k8s-key-pair"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.runner_sg.id]

  tags = {
    Name = "github-runner"
  }

  user_data = file("${path.module}/scripts/github-runner.sh")
}

resource "aws_security_group" "runner_sg" {
  name        = "github-runner-sg"
  description = "Allow access to EKS and internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH (you can restrict to your IP)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

