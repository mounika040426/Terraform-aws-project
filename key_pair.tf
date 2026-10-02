resource "aws_key_pair" "aws_vm" {
  key_name   = "aws_vm-key"
  public_key = file("~/.ssh/aws_vm-key.pub")
}
