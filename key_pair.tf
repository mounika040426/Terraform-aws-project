resource "aws_key_pair" "aws_vm" {
  count      = var.public_key != "" ? 1 : 0
  key_name   = "aws_vm-key"
  public_key = var.public_key
}
