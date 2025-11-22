terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"   # TODO: replace with your bucket name
    key            = "templatecluster/terraform.tfstate"
    region         = "us-east-1"                 # TODO: set appropriate region
    dynamodb_table = "terraform-lock-table"       # Optional: DynamoDB table for state locking
    encrypt        = true
  }
}
