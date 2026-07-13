
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access_block" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "null_resource" "sync_files" {
  triggers = {
    bucket_id  = aws_s3_bucket.frontend_bucket.id
    files_hash = sha1(join("", [for f in fileset("../../frontend/", "*") : filesha1("../../frontend/${f}")]))
  }

  provisioner "local-exec" {
    command = "aws s3 sync ../frontend/ s3://${aws_s3_bucket.frontend_bucket.bucket} --delete"
  }
}