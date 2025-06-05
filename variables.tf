
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key file used for the key pair"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB and Target Group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB and Autoscaling Group"
  type        = list(string)
}
