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