variable "validate_function" {
  type = string
}
variable "validate_role_name" {
  type = string
}

variable "api_gw" {
  type = string
}
variable "api_gw_ws" {
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

variable "medium_function_arn" {
  type = string
}
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

####
variable "connect_function" {
  type = string
}
variable "connect_handler_role_name" {
  type = string
}
variable "get_connection_id_function" {
  type = string
}
variable "get_connection_id_handler_role_name" {
  type = string
}
###
variable "watermark_sqs_arn" {
  type = string
}
variable "watermark_sqs_url" {
  type = string
}
variable "watermark_function_arn" {
  type = string
}
variable "watermark_role_name" {
  type = string
}