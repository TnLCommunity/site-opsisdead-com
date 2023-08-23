locals {
  opsisdead_environment_name        = "opsisdead-com" # THIS MUST BE UPDATED IF COPIED
  opsisdead_environment_domain_name = "opsisdead.com"
  clubdoers_environment_name        = "clubdoers-com" # THIS MUST BE UPDATED IF COPIED
  clubdoers_environment_domain_name = "clubdoers.com"
}

# manage secrets for this environment via aws secrets manager for secret
# versioning and aws access control over secrets
data "aws_secretsmanager_secret_version" "env" {
  secret_id = "tnlcommunity/static-sites/${local.opsisdead_environment_name}"
  provider  = aws
}

locals {
  secrets = jsondecode(
    data.aws_secretsmanager_secret_version.env.secret_string
  )
}

data "cloudflare_zone" "opsisdead-com" {
  name = local.opsisdead_environment_domain_name
}

module "demo-acm" {
  source = "../modules/acm-with-cloudflare/"

  domain_name        = local.opsisdead_environment_domain_name
  cloudflare_zone_id = data.cloudflare_zone.opsisdead-com.id

  providers = {
    aws = aws.acm
  }
}


module "opsisdead-com-static-site" {
  source  = "catalystsquad/staticsite/aws"
  version = "~> 1.1.0"

  website_domain = local.opsisdead_environment_domain_name
  bucket_name    = local.opsisdead_environment_domain_name

  acm_certificate_arn    = module.demo-acm.acm_certificate_arn
  create_acm_certificate = false
  create_site_records    = false

  cloudfront_custom_error_responses = [{
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }]

  providers = {
    aws.main = aws
    aws.acm  = aws.acm
  }
}

resource "cloudflare_record" "opsisdead-com" {
  zone_id = data.cloudflare_zone.opsisdead-com.id
  name    = local.opsisdead_environment_domain_name
  value   = module.opsisdead-com-static-site.cloudfront_domain_name
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

data "cloudflare_zone" "clubdoers-com" {
  name = local.clubdoers_environment_domain_name
}

module "demo-acm" {
  source = "../modules/acm-with-cloudflare/"

  domain_name        = local.clubdoers_environment_domain_name
  cloudflare_zone_id = data.cloudflare_zone.clubdoers-com.id

  providers = {
    aws = aws.acm
  }
}
module "clubdoers-com-static-site" {
  source  = "catalystsquad/staticsite/aws"
  version = "~> 1.1.0"

  website_domain = local.clubdoers_environment_domain_name
  bucket_name    = local.clubdoers_environment_domain_name

  acm_certificate_arn    = module.demo-acm.acm_certificate_arn
  create_acm_certificate = false
  create_site_records    = false

  cloudfront_custom_error_responses = [{
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }]

  providers = {
    aws.main = aws
    aws.acm  = aws.acm
  }
}

resource "cloudflare_record" "clubdoers-com" {
  zone_id = data.cloudflare_zone.clubdoers-com.id
  name    = local.clubdoers_environment_domain_name
  value   = module.clubdoers-com-static-site.cloudfront_domain_name
  type    = "CNAME"
  ttl     = 300
  proxied = false
}
