
# Project 4: Scalable EC2 Deployment with NGINX, Load Balancing, Auto Scaling, and Terraform Cloud

This project showcases how to provision a scalable web infrastructure on AWS using Terraform. It includes:

- EC2 instance with NGINX web server
- Load Balancer and Auto Scaling configuration
- Terraform Cloud for remote state management
- Code hosted and versioned via GitHub

## Tech Stack

- Terraform
- AWS EC2, Security Groups, Load Balancer, Auto Scaling
- NGINX Web Server
- Terraform Cloud
- GitHub

## Usage

Update the `terraform.tfvars` file with your key pair and AMI details. Then run:

```bash
terraform init
terraform plan
terraform apply
```

After deployment, access your application via the public IP output or load balancer DNS name.
