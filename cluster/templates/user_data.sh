#!/bin/bash

# TODO: Use script from http://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html

yum install -y awslogs jq aws-cli

# ECS config
{
  echo "ECS_CLUSTER=${cluster}"
} >> /etc/ecs/ecs.config



echo "Done"