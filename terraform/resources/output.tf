output "invoke_url" {
  value = module.api_gw.invoke_url
}

output "invoke_url_ws" {
  value = module.api_gw.invoke_url_ws
}

output "metadata_queue_url" {
  value = module.sqs.metadata_queue_url
}