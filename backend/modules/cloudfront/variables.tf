variable "bucket_arn" {
  description = "O ARN do bucket S3 para ser usado como origem do cloudfront"
  type        = string
}
variable "bucket_name" {
  description = "O nome do bucket S3 para ser usado como origem do cloudfront (usado no domínio da origem)"
  type        = string
}