
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Troubleshooting connectivity issues between tasks in an Amazon ECS cluster using service discovery
---

This incident type involves connectivity issues between tasks in an Amazon ECS (Elastic Container Service) cluster that uses service discovery. Service discovery is a mechanism that allows services to be discovered and accessed by other services without needing to know their IP addresses. There are several potential areas to investigate when facing connectivity issues, including service discovery configuration, DNS resolution, task definition and network mode, security groups, task IAM role, VPC configuration, ECS agent, ECS service event messages, logs, application-level configuration, and health checks. Troubleshooting steps need to be taken to resolve these issues.

### Parameters
```shell
export SERVICE_DISCOVERY_SERVICE_ID="PLACEHOLDER"

export TASK_DEFINITION_ARN="PLACEHOLDER"

export TASK_ARN="PLACEHOLDER"

export CLUSTER_NAME="PLACEHOLDER"

export VPC_ID="PLACEHOLDER"
```

## Debug

### Confirm that the ECS service is associated with a Service Discovery namespace
```shell
aws servicediscovery get-service --id ${SERVICE_DISCOVERY_SERVICE_ID}
```

### Check if the DNS records of the tasks are correctly registered in the AWS Cloud Map service
```shell
aws servicediscovery list-instances --service-id ${SERVICE_DISCOVERY_SERVICE_ID}
```

### Review the task definition and check the network mode
```shell
aws ecs describe-task-definition --task-definition ${TASK_DEFINITION_ARN} 
```

### Confirm that the tasks are launched in the expected subnets
```shell
aws ecs describe-tasks --tasks ${TASK_ARN} --cluster ${CLUSTER_NAME}
```

### Ensure health checks are correctly set up
```shell
#!/bin/bash



for service_arn in $(aws ecs list-services --cluster ${CLUSTER_NAME} --query 'serviceArns[]' --output text);

do

    service_task_def=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --services $service_arn --query 'services[0].taskDefinition' --output text)

    service_tasks=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} --service-name $service_arn --query 'taskArns[]' --output text)

    if [[ $service_task_def == ${TASK_DEFINITION_ARN} ]] && [[ $service_tasks == ${TASK_ARN} ]]; then

        service_arn=$service_arn

    fi

done



aws ecs describe-services --services $service_arn --cluster ${CLUSTER_NAME}
```

### Review security groups associated with the task or service to make sure inbound and outbound traffic is allowed between tasks
```shell
#!/bin/bash



for service_arn in $(aws ecs list-services --cluster ${CLUSTER_NAME} --query 'serviceArns[]' --output text);

do

    service_task_def=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --services $service_arn --query 'services[0].taskDefinition' --output text)

    service_tasks=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} --service-name $service_arn --query 'taskArns[]' --output text)

    if [[ $service_task_def == ${TASK_DEFINITION_ARN} ]] && [[ $service_tasks == ${TASK_ARN} ]]; then

        service_arn=$service_arn

    fi

done



security_group_id=$(aws ecs describe-services --services $service_arn --cluster ${CLUSTER_NAME} --query 'services[0].networkConfiguration.awsvpcConfiguration.securityGroups[]' --output text)



aws ec2 describe-security-groups --group-ids $security_group_id
```

## Repair

### Associate the service with the service registries
```shell


#!/bin/bash



for service_arn in $(aws ecs list-services --cluster ${CLUSTER_NAME} --query 'serviceArns[]' --output text);

do

    service_task_def=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --services $service_arn --query 'services[0].taskDefinition' --output text)

    service_tasks=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} --service-name $service_arn --query 'taskArns[]' --output text)

    if [[ $service_task_def == ${TASK_DEFINITION_ARN} ]] && [[ $service_tasks == ${TASK_ARN} ]]; then

        ECS_SERVICE=$service_arn

    fi

done





service_discovery_service_arn=$(aws servicediscovery get-service --id ${SERVICE_DISCOVERY_SERVICE_ID} --query "Service.Arn" --output text)



# Check the ECS service's configuration

aws ecs describe-services --services $ECS_SERVICE







# If the service is not associated with a Service Discovery namespace, associate it with one

if [[ ! $(aws ecs describe-services --services $ECS_SERVICE --query 'services[0].serviceRegistries[0].registryArn' --output text) ]]; then

    aws ecs update-service --service $ECS_SERVICE --service-registries registryArn=$service_discovery_service_arn

fi


```

### Enable DNS resolution for the VPC
```shell


#!/bin/bash



# Set variables

VPC_ID=${VPC_ID}



# Enable DNS resolution for the VPC

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support "{\"Value\":true}"
```