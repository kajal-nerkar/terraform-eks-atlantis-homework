# dns.tf

# 1) Find your public hosted zone in Route 53
data "aws_route53_zone" "main" {
  name         = "example.com."   # ← your domain, trailing dot required
  private_zone = false
}

# 2) Look up the Kubernetes NLB by its service tag
data "aws_lb" "atlantis_nlb" {
  # This tag is automatically added by AWS for your Service named "atlantis" in namespace "atlantis"
  tags = {
    "service.kubernetes.io/service-name" = "atlantis/atlantis"
  }
}

# 3) Create a DNS record pointing at that NLB
resource "aws_route53_record" "atlantis" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "atlantis"               # → atlantis.example.com
  type    = "CNAME"                  # Use "A" + alias blocks if you prefer
  ttl     = 300
  records = [
    data.aws_lb.atlantis_nlb.dns_name
  ]
}
