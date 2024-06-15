data "aws_acm_certificate" "certificate" {
  domain = var.domain_name
}
