data "aws_iam_role" "iamr" {
  name = "EC2forSSM"
 
}

data "aws_iam_instance_profile" "iamrp" {
  name = "EC2forSSM"
  
}