#!/bin/bash

SERVICE=$1
ECR_URL="198302589618.dkr.ecr.ap-south-1.amazonaws.com"

echo "Deploying service: $SERVICE"

case $SERVICE in
  service-a) PORT=5000 ;;
  service-b) PORT=5001 ;;
  service-c) PORT=5002 ;;
  *) echo "Invalid service"; exit 1 ;;
esac

echo "Using port: $PORT"

# Login to ECR (will work after IAM role)
aws ecr get-login-password --region ap-south-1 \
| sudo docker login --username AWS --password-stdin $ECR_URL

# Pull image
sudo docker pull $ECR_URL/$SERVICE:latest

# Stop/remove old container
sudo docker rm -f $SERVICE || true

# Run container
sudo docker run -d \
  --name $SERVICE \
  -p $PORT:5000 \
  --restart always \
  $ECR_URL/$SERVICE:latest

echo "Deployment completed 🚀"
