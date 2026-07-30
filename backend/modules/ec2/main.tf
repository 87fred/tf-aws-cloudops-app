resource "aws_instance" "ec2_test" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"

  tags = {
    Name = "aws-cloudops-app-ec2-test"
  }
}