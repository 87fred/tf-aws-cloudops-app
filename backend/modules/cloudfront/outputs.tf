output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID da distribuição Cloudfront"
  value       = aws_cloudfront_distribution.s3_distribution.id
}