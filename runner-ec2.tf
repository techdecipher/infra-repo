resource "aws_iam_role" "github_runner_role" {
  name = "github-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "github_runner_policy" {
  name = "github-runner-policy"
  role = aws_iam_role.github_runner_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "runner_profile" {
  name = "github-runner-instance-profile"
  role = aws_iam_role.github_runner_role.name
}

resource "aws_security_group" "runner_sg" {
  name        = "github-runner-sg"
  description = "Allow SSH access"
  vpc_id      = module.vpc.vpc_id

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

resource "aws_instance" "github_runner" {
  ami                         = "ami-07caf09b362be10b8" # Ubuntu 22.04 in us-east-1
  instance_type               = "t2.medium"
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = "k8s-key-pair"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.runner_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.runner_profile.name

  tags = {
    Name = "github-runner"
  }

  user_data = file("${path.module}/scripts/github-runner.sh")
}


resource "aws_instance" "github_runner_ubuntu" {
  ami                         = "ami-0a7d80731ae1b2435" # Ubuntu 20.04 LTS for us-east-1
  instance_type               = "t2.medium"
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = "k8s-key-pair"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.runner_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.runner_profile.name

  tags = {
    Name = "github-runner-ubuntu"
  }

  user_data = file("${path.module}/scripts/github-runner.sh")
}

