resource "aws_route53_zone" "my_zone" {
  name = "my-very-unique-website.com"
}

# Add a DNS-record on the AWS Route53 zone that points to to the URL of a load balancer.
resource "aws_route53_record" "my_record" {
  zone_id =  aws_route53_zone.my_zone.id
  name    = "asp.my-very-unique-website.com"
  type    = "CNAME"
  ttl     = "300"
  
  records = [kubernetes_service.asp-app_service.status.0.load_balancer.0.ingress.0.hostname]
  depends_on = [ aws_route53_zone.my_zone ]
}

resource "aws_acm_certificate" "my_cert" {
  domain_name = "my-very-unique-website.com"
  subject_alternative_names = ["*.my-very-unique-website.com", "asp.my-very-unique-website.com"]
  validation_method = "DNS"
}

resource "aws_route53_record" "my_records" {
  for_each = {
    for dvo in aws_acm_certificate.my_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.my_zone.zone_id
  
  depends_on = [ aws_route53_zone.my_zone ]
}

resource "aws_acm_certificate_validation" "my_cert" {
  certificate_arn         = aws_acm_certificate.my_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.my_records : record.fqdn]
  
  depends_on = [ aws_route53_zone.my_zone ]
}
