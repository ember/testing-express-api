terragrunt = {
  remote_state {
    backend = "s3"
    config {
      bucket         = "tf-express-api"
      key            = "api-app/terraform.tfstate"
      dynamodb_table = "tf-lock-state"
      region         = "eu-west-2"
    }
  }
}
