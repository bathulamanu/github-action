#!/bin/bash

SERVICE=$1

echo "Deploying service: $SERVICE"

ECR_URL="198302589618.dkr.ecr.ap-south-1.amazonaws.com"

# Set port based on service
if [ "$SERVICE" = "service-a" ]; then PORT=5000; fi
if [ "$SERVICE" = "service-b" ]; then PORT=5001; fi
if [ "$SERVICE" = "service-c" ]; then PORT=5002; fi

echo "Using port: $PORT"

# Pull latest image
docker pull $ECR_URL/$SERVICE:latest

# Stop and remove old container
docker stop $SERVICE || true
docker rm $SERVICE || true

# Run new container
docker run -d \
  --name $SERVICE \
  -p $PORT:$PORT \
  --restart always \
  $ECR_URL/$SERVICE:latest

echo "Deployment completed for $SERVICE"
