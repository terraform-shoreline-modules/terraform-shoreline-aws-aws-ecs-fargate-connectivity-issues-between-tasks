

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