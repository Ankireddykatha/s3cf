
# cloudfront id 
output "cloudfrontid" {
  value = aws_cloudfront_distribution.cdn.id
}
output "cloudfrontURL" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
output "bucketname" {
  value = aws_s3_bucket.bucket.id
} 

