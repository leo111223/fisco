# AWS Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-leo"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# IAM Role for AWS Amplify (Still keeping role in case needed)
data "aws_iam_role" "amplify_role" {
  name = "amplify-service-role"
}

resource "aws_iam_policy_attachment" "amplify_full_access" {
  name       = "amplify-full-access"
  roles      = [data.aws_iam_role.amplify_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

# AWS Amplify App (Removed build_spec)
resource "aws_amplify_app" "plaid_app" {
  name       = "FiscAI"
  repository = "https://github.com/leo111223/fisco.git"
  oauth_token = var.github_token
  iam_service_role_arn = data.aws_iam_role.amplify_role.arn
  enable_branch_auto_deletion = true
}

resource "aws_amplify_branch" "main_branch" {
  app_id      = aws_amplify_app.plaid_app.id
  branch_name = var.branch_name
  enable_auto_build = true
  stage             = "PRODUCTION"
}

# DynamoDB Table
resource "aws_dynamodb_table" "transactions" {
  name           = "transactions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "transaction_id"

  attribute {
    name = "transaction_id"
    type = "S"
  }
}

# Existing S3 bucket for frontend
data "aws_s3_bucket" "existing_bucket" {
  bucket = "your-existing-s3-bucket-name"
}

resource "aws_cloudfront_distribution" "fiscai_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.existing_bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}



# Cognito User Pool
resource "aws_cognito_user_pool" "fiscai_user_pool" {
  name = "fiscai-user-pool"
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "fiscai_user_pool_client" {
  name         = "fiscai-client"
  user_pool_id = aws_cognito_user_pool.fiscai_user_pool.id
  generate_secret = false
  allowed_oauth_flows_user_pool_client = true
}

