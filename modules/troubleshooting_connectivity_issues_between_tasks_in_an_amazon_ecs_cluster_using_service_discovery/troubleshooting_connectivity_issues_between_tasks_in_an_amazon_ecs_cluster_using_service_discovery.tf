resource "shoreline_notebook" "troubleshooting_connectivity_issues_between_tasks_in_an_amazon_ecs_cluster_using_service_discovery" {
  name       = "troubleshooting_connectivity_issues_between_tasks_in_an_amazon_ecs_cluster_using_service_discovery"
  data       = file("${path.module}/data/troubleshooting_connectivity_issues_between_tasks_in_an_amazon_ecs_cluster_using_service_discovery.json")
  depends_on = [shoreline_action.invoke_ecs_service_check,shoreline_action.invoke_ecs_security_group,shoreline_action.invoke_ecs_service_discovery_association,shoreline_action.invoke_enable_dns_vpc]
}

resource "shoreline_file" "ecs_service_check" {
  name             = "ecs_service_check"
  input_file       = "${path.module}/data/ecs_service_check.sh"
  md5              = filemd5("${path.module}/data/ecs_service_check.sh")
  description      = "Ensure health checks are correctly set up"
  destination_path = "/tmp/ecs_service_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "ecs_security_group" {
  name             = "ecs_security_group"
  input_file       = "${path.module}/data/ecs_security_group.sh"
  md5              = filemd5("${path.module}/data/ecs_security_group.sh")
  description      = "Review security groups associated with the task or service to make sure inbound and outbound traffic is allowed between tasks"
  destination_path = "/tmp/ecs_security_group.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "ecs_service_discovery_association" {
  name             = "ecs_service_discovery_association"
  input_file       = "${path.module}/data/ecs_service_discovery_association.sh"
  md5              = filemd5("${path.module}/data/ecs_service_discovery_association.sh")
  description      = "Associate the service with the service registries"
  destination_path = "/tmp/ecs_service_discovery_association.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "enable_dns_vpc" {
  name             = "enable_dns_vpc"
  input_file       = "${path.module}/data/enable_dns_vpc.sh"
  md5              = filemd5("${path.module}/data/enable_dns_vpc.sh")
  description      = "Enable DNS resolution for the VPC"
  destination_path = "/tmp/enable_dns_vpc.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_ecs_service_check" {
  name        = "invoke_ecs_service_check"
  description = "Ensure health checks are correctly set up"
  command     = "`chmod +x /tmp/ecs_service_check.sh && /tmp/ecs_service_check.sh`"
  params      = ["TASK_DEFINITION_ARN","CLUSTER_NAME","TASK_ARN"]
  file_deps   = ["ecs_service_check"]
  enabled     = true
  depends_on  = [shoreline_file.ecs_service_check]
}

resource "shoreline_action" "invoke_ecs_security_group" {
  name        = "invoke_ecs_security_group"
  description = "Review security groups associated with the task or service to make sure inbound and outbound traffic is allowed between tasks"
  command     = "`chmod +x /tmp/ecs_security_group.sh && /tmp/ecs_security_group.sh`"
  params      = ["TASK_DEFINITION_ARN","CLUSTER_NAME","TASK_ARN"]
  file_deps   = ["ecs_security_group"]
  enabled     = true
  depends_on  = [shoreline_file.ecs_security_group]
}

resource "shoreline_action" "invoke_ecs_service_discovery_association" {
  name        = "invoke_ecs_service_discovery_association"
  description = "Associate the service with the service registries"
  command     = "`chmod +x /tmp/ecs_service_discovery_association.sh && /tmp/ecs_service_discovery_association.sh`"
  params      = ["SERVICE_DISCOVERY_SERVICE_ID","TASK_DEFINITION_ARN","CLUSTER_NAME","TASK_ARN"]
  file_deps   = ["ecs_service_discovery_association"]
  enabled     = true
  depends_on  = [shoreline_file.ecs_service_discovery_association]
}

resource "shoreline_action" "invoke_enable_dns_vpc" {
  name        = "invoke_enable_dns_vpc"
  description = "Enable DNS resolution for the VPC"
  command     = "`chmod +x /tmp/enable_dns_vpc.sh && /tmp/enable_dns_vpc.sh`"
  params      = ["VPC_ID"]
  file_deps   = ["enable_dns_vpc"]
  enabled     = true
  depends_on  = [shoreline_file.enable_dns_vpc]
}

