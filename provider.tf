terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket                      = "mio-terraform-state-bucket"
    key                         = "dev.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://10.10.10.11:4566"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}


provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    dynamodb       = "http://10.10.10.11:4566"
    s3             = "http://10.10.10.11:4566"
    sqs            = "http://10.10.10.11:4566"
    sns            = "http://10.10.10.11:4566"
    ssm            = "http://10.10.10.11:4566"
    secretsmanager = "http://10.10.10.11:4566"
    iam            = "http://10.10.10.11:4566"
    sts            = "http://10.10.10.11:4566"
    lambda         = "http://10.10.10.11:4566"
    ec2            = "http://10.10.10.11:4566"
  }
}
