provider "aws" {
  region = var.myregion
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_s3_bucket" "bucket" {
      bucket = "${var.Bucketname}"
     # acl    = "public-read"
      #policy = "${file("s3.json")}"
      tags = {
        Name = "${var.stack}-bucket"
    }
    
    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }

}


}


locals {
  s3_origin_id = "myS3Origin"
}



resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = aws_s3_bucket.bucket.id
}

# cloudfront
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "${aws_s3_bucket.bucket.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
    }
    
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "cdn"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

    custom_error_response {
        error_code = 403 
        response_code = 200 
        response_page_path = "/index.html"

    }
    custom_error_response {
        error_code = 404
        response_code = 200
        response_page_path = "/index.html"

    }
    restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

#### if using custom domain comment this code   
  viewer_certificate {
    acm_certificate_arn      = "${var.acm-certificate-arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "${var.minimum_client_tls_protocol_version}"
  }

  aliases = ["${var.aliascname}"]


  tags = {
    Environment = "${var.stack}"
  }

  # end

### if not using custom domain uncomment this code 

/*
  viewer_certificate {
    cloudfront_default_certificate = true
  }
*/
# end

  
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
      },
      "Resource": "${aws_s3_bucket.bucket.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_route53_record" "root_domain" {
  zone_id = "${var.route53_zone_id}"
  name = "${var.asset_cf_domain}"
  type = "A"

   alias {
     name = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}