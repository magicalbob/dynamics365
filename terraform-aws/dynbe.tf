resource "aws_instance" "dynbe" {
  count         = 1
  ami           = data.aws_ami.dynamics.id
  instance_type = "t2.micro"
  tags = {
    name = "dynbe"
  }
}
