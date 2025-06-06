terraform { 
  cloud { 
    
    organization = "Terraform_CloudORG" 

    workspaces { 
      name = "terraform-ec2-asg-alb-nginx" 
    } 
  } 
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaaIhUMyjAf1gBmTZdwMNyIA6v1SdTDZ0dBjD/uJr7N+5XTt8jlGZgakmQNzgbSWbsHSms31QDNFp7dqvO/W/h+wGa8KyxbaxJbvscfYoD2k5KUJ5Zd3no30iNhiqWQAwyMNmrcjU4eRL88k0uCLH683uQjU1nsQW8B3+3zWMDFIhle+LiaKBhmuFpgDqjbMICh3/r16jwNBPN9JuRdbNECQGLM6+xbKG4RUQ4f+ZpS6DM67im/WbqeXXfvteORk8Cao/I6V3dN1BclNW6uwmu1BaUQRFSFw7p/obmi3wt1sEI70HubSA6yHIwmkFy1M0gEygBhQ97wyFyDs/bPCO1"
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"

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

resource "aws_launch_template" "web_template" {
  name_prefix   = "nginx-launch-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
  yum update -y
  amazon-linux-extras enable nginx1
  yum install -y nginx
  systemctl start nginx
  systemctl enable nginx

  # Wait for NGINX to fully start and create its root folder
  sleep 5

  echo "<h1>Welcome to Project 4 with ALB and Autoscaling From TechBro</h1>" > /usr/share/nginx/html/index.html
EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.subnet_ids
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]
  health_check_type = "EC2"
  tag {
    key                 = "Name"
    value               = "nginx-instance"
    propagate_at_launch = true
  }
}

resource "aws_lb" "web_alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "web_tg" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
