resource "aws_instance" "ec2" {
  ami           = var.ami
  instance_type = "t3.small"
  subnet_id     = aws_subnet.prv.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile = data.aws_iam_instance_profile.iamrp.name
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
 }

  tags = {
    Name = "envMachine"
  }
}


resource "aws_ebs_volume" "ebs" {
  size              = 8
  availability_zone = "us-east-1a"
  type              = "gp3"
  encrypted         = true
  tags = {
    Name = "envEbs"
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.ec2.id
}

