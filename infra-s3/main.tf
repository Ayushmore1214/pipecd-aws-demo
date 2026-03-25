provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "pipecd-gitops-demo-ayush-001" # Remember to make this unique!
  tags = {
    Environment = "Dev"
    ManagedBy   = "PipeCD"
  }
}