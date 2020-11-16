
variable "myregion" {
    type = "string"
    #default = "us-west-2" # region_name
}

variable "access_key" {
  type    = "string"
  
}
variable "secret_key" {
  type   = "string"
  
}


variable "route53_zone_id" {
  type   = "string"
  
}



variable "asset_cf_domain" {
  type = "string"
  #default = "test"   #record_name
}
variable "Bucketname" {
  type = "string"
  #default = "test.example.com"   # bucket_name
  
}

variable "aliascname" {
    type = "string"
   #default = "test.example.com"    # Alternate Domain Names(CNAMEs)
  
}

variable "acm-certificate-arn" {
  type = "string"
  #default = "arn:aws:acm:us-east-1:333333333333333:certificate/44444444444444444"   # acm-certificate-arn
  
}
variable "minimum_client_tls_protocol_version" {
  type        = "string"
  description = "CloudFront viewer certificate minimum protocol version"
  default     = "TLSv1"
}

variable "stack" {
  type = "string"
  #default = "test"  #naming convention for tags
  
}



