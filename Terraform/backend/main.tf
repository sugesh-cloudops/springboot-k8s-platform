provider "aws" {
  region = "us-west-2"
}
resource "aws_s3_bucket" "name" {
  bucket = "terraform-eks-state-s3-bucket-crewmeister"
    lifecycle {
    prevent_destroy = false
    }
}

resource aws_dynamodb_table "name" {
    name = "terraform-eks-state-lock-table-crewmeister"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S" 
  
}
}