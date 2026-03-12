###############################################################################
# Hosted Zone: the16oracles.io
###############################################################################

resource "aws_route53_zone" "the16oracles_io" {
  name = "the16oracles.io"

  lifecycle {
    prevent_destroy = true
  }
}

###############################################################################
# NS Record (auto-created with hosted zone, managed to prevent drift)
###############################################################################

resource "aws_route53_record" "the16oracles_io_ns" {
  zone_id = aws_route53_zone.the16oracles_io.zone_id
  name    = "the16oracles.io"
  type    = "NS"
  ttl     = 172800

  records = [
    "ns-1234.awsdns-00.org.", # TODO: Replace with actual NS records after import
    "ns-5678.awsdns-00.co.uk.",
    "ns-910.awsdns-00.net.",
    "ns-11.awsdns-00.com.",
  ]
}

###############################################################################
# SOA Record
###############################################################################

resource "aws_route53_record" "the16oracles_io_soa" {
  zone_id = aws_route53_zone.the16oracles_io.zone_id
  name    = "the16oracles.io"
  type    = "SOA"
  ttl     = 900

  records = [
    "ns-0000.awsdns-00.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400", # TODO: Replace after import
  ]
}

###############################################################################
# TXT Record: _dmarc
###############################################################################

resource "aws_route53_record" "dmarc_txt" {
  zone_id = aws_route53_zone.the16oracles_io.zone_id
  name    = "_dmarc.the16oracles.io"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=none", # TODO: Verify actual DMARC record value after import
  ]
}

###############################################################################
# CNAME Record: _domainconnect
###############################################################################

resource "aws_route53_record" "domainconnect_cname" {
  zone_id = aws_route53_zone.the16oracles_io.zone_id
  name    = "_domainconnect.the16oracles.io"
  type    = "CNAME"
  ttl     = 300

  records = [
    "_domainconnect.gd.domaincontrol.com", # TODO: Verify after import
  ]
}

###############################################################################
# A Record: api.the16oracles.io (alias to NLB or API Gateway)
###############################################################################

resource "aws_route53_record" "api_a" {
  zone_id = aws_route53_zone.the16oracles_io.zone_id
  name    = "api.the16oracles.io"
  type    = "A"

  alias {
    name                   = var.nlb_dns_name # TODO: Verify alias target after import
    zone_id                = var.nlb_zone_id
    evaluate_target_health = true
  }
}

###############################################################################
# CNAME Record: ACM validation for api.the16oracles.io
###############################################################################

resource "aws_route53_record" "api_acm_validation" {
  zone_id = aws_route53_zone.the16oracles_io.zone_id
  name    = "_placeholder.api.the16oracles.io" # TODO: Replace with actual ACM validation CNAME name after import
  type    = "CNAME"
  ttl     = 300

  records = [
    "_placeholder.acm-validations.aws." # TODO: Replace with actual ACM validation value after import
  ]
}

###############################################################################
# A Record: svcs.the16oracles.io
###############################################################################

resource "aws_route53_record" "svcs_a" {
  zone_id = aws_route53_zone.the16oracles_io.zone_id
  name    = "svcs.the16oracles.io"
  type    = "A"

  alias {
    name                   = var.nlb_dns_name # TODO: Verify alias target after import
    zone_id                = var.nlb_zone_id
    evaluate_target_health = true
  }
}

###############################################################################
# ACM Certificate: api.rookiecard.xyz
###############################################################################

resource "aws_acm_certificate" "api_rookiecard_xyz" {
  domain_name       = "api.rookiecard.xyz"
  validation_method = "DNS" # TODO: Verify validation method after import

  tags = {
    Name = "api.rookiecard.xyz"
  }

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# ACM Certificate: api.the16oracles.io
###############################################################################

resource "aws_acm_certificate" "api_the16oracles_io" {
  domain_name       = "api.the16oracles.io"
  validation_method = "DNS" # TODO: Verify validation method after import

  tags = {
    Name = "api.the16oracles.io"
  }

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# ACM Certificate: svcs.the16oracles.io
###############################################################################

resource "aws_acm_certificate" "svcs_the16oracles_io" {
  domain_name       = "svcs.the16oracles.io"
  validation_method = "DNS" # TODO: Verify validation method after import

  tags = {
    Name = "svcs.the16oracles.io"
  }

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# ACM Certificate: www.the16oracles.io
###############################################################################

resource "aws_acm_certificate" "www_the16oracles_io" {
  domain_name       = "www.the16oracles.io"
  validation_method = "DNS" # TODO: Verify validation method after import

  tags = {
    Name = "www.the16oracles.io"
  }

  lifecycle {
    create_before_destroy = true
  }
}
