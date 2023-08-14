terraform {
  backend "s3" {
    bucket         = "tnl-static-sites-terraform-state"
    key            = "tnlcommunity/opsisdead-com" # THIS MUST BE UPDATED IF COPIED
    region         = "us-west-2"
    dynamodb_table = "static-sites-terraform-state"
  }
}
