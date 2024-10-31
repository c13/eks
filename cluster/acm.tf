resource "aws_acm_certificate" "grafana" {
  domain_name       = "grafana-eks.zetarin.org"
  validation_method = "DNS"  # or "EMAIL" based on your preferred method

  subject_alternative_names = [
    "grafana.zetarin.org"
  ]
}

resource "aws_route53_record" "grafana" {
  for_each = {
    for dvo in aws_acm_certificate.grafana.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = "${var.dns_zone}"
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "grafana" {
  certificate_arn         = aws_acm_certificate.grafana.arn
  validation_record_fqdns = [for record in aws_route53_record.grafana : record.fqdn]
}