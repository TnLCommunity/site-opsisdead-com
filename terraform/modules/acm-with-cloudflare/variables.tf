# required
variable "domain_name" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

# optional
variable "subject_alternative_names" {
  type = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
