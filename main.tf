provider "aws" {
  region = "us-west-2"
}

# Define a resource block for an AWS EC2 instance
resource "aws_instance" "example" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "MyExampleInstance"
  }

  key_name = "my-key-pair"
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}