variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.nano"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "key_pair_name" {
  description = "Name of the existing EC2 key pair for SSH access"
  type        = string
  default     = "k8s-key-pair" # replace with your actual key name
}
