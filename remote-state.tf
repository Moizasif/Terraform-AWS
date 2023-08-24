terraform {
  backend "s3" {
    bucket         = "willh-state-bucket-8222023"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "my-terraform-locks"
  }
}
