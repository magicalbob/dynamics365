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

resource "aws_instance" "allinone" {
  count         = 1
  ami           = data.aws_ami.dynamics.id
  instance_type = "t2.micro"
  tags = {
    name = "allinone"
  }
}
