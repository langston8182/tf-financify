terraform {
  backend "s3" {
    bucket = "cmarchive-financify-tfstate"
    key    = "terraform.tfstate"
    region = "eu-west-3"
    dynamodb_table = "financify-state-locking"
  }
}