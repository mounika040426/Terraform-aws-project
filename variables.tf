variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-devops-project"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "Public subnet 1 CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "Public subnet 2 CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_subnet_2_cidr" {
  description = "Private subnet 2 CIDR"
  type        = string
  default     = "10.0.12.0/24"
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  default     = ""
}
