resource "aws_instance" "dynsql" {
  count         = 1
  ami           = data.aws_ami.dynamics.id
  instance_type = "t2.micro"
  tags = {
    name = "dynsql"
  }
}
