resource "aws_instance" "app" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_1.id

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name
  key_name             = aws_key_pair.aws_vm.key_name
  user_data            = <<-EOF
                              #!/bin/bash
                              apt update -y
                              apt install -y docker
                              systemctl enable docker
                              systemctl start docker
                              usermod -aG docker ec2-user
                              EOF

  tags = {
    Name = "java-rey-app"
  }
}
