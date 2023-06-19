terraform {
  backend "s3" {
    bucket = "burency-codedeploy-bucket"
    region = "us-east-1"
    key    = "jenkins-server/terraform.tfstate"
  }
}
