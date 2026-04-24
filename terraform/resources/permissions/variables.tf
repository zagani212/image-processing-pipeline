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

variable "sqs_arn" {
  type = string  
}