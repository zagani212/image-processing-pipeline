variable "validate_function" {
  type = string
}
variable "validate_role_name" {
  type = string
}

variable "api_gw" {
  type = string
}

variable "metadata_sqs_arn" {
  type = string  
}

variable "bucket_arn" {
  type = string  
}
######
variable "metadata_role_name" {
  type = string
}

variable "metadata_function_arn" {
  type = string
}

variable "dynamo_table_arn" {
  type = string  
}
####
variable "thumbnail_role_name" {
  type = string
}
variable "medium_role_name" {
  type = string
}

# variable "medium_function_arn" {
#   type = string
# }
variable "thumbnail_function_arn" {
  type = string
}
variable "thumbnail_sqs_arn" {
  type = string  
}
variable "medium_sqs_arn" {
  type = string  
}

variable "thumbnail_sqs_url" {
  type = string  
}
variable "medium_sqs_url" {
  type = string  
}

variable "sns_arn" {
  type = string  
}