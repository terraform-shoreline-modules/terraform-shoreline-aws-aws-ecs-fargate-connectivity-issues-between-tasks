terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "troubleshooting_connectivity_issues_between_tasks_in_an_amazon_ecs_cluster_using_service_discovery" {
  source    = "./modules/troubleshooting_connectivity_issues_between_tasks_in_an_amazon_ecs_cluster_using_service_discovery"

  providers = {
    shoreline = shoreline
  }
}