resource "aws_api_gateway_domain_name" "apigw_domain" {
  domain_name              = var.domain_name
  regional_certificate_arn = data.aws_acm_certificate.certificate.arn
  security_policy          = local.security_policy
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  api_id      = var.rest_api_id
  domain_name = var.domain_name
  stage_name  = var.stage_name
}

resource "aws_route53_record" "route_apigw" {
  name    = var.domain_name
  type    = local.route_type
  zone_id = var.zone_id
  ttl     = local.ttl
  records = [aws_api_gateway_domain_name.apigw_domain.regional_domain_name]
}