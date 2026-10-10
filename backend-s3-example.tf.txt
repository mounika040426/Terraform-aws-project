terraform {
  backend "s3" {
    bucket           = "mounika-terraform-state-172170847687-ap-south-1"
    key              = "aws-devops-project/terraform.tfstate"
    region           = "ap-south-1"
    encrypt          = true
    use_lockfile     = true
   }
}
