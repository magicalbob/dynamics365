resource "aws_instance" "dynadir" {
  count         = 1
  ami           = data.aws_ami.dynamics.id
  instance_type = "t2.medium"
  tags = {
    name = "dynadir"
  }
}
