output "invoke_url" {
  value = module.api_gw.invoke_url
}

output "metadata_queue_url" {
  value = module.sqs.metadata_queue_url
}