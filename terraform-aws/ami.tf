data "aws_ami" "dynamics" {
  most_recent = true

  filter {
    name   = "name"
    values = ["dynamics"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["841411968712"]
}
