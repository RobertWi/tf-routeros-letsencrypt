terraform {
  backend "s3" {
    bucket         = "tf-mikrotik-letsencrypt-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "tf-mikrotik-letsencrypt-lock"
    profile        = "AdministratorAccess-846252055641"
  }
}
