#!/bin/bash

SERVICE=$1
ECR_URL="198302589618.dkr.ecr.ap-south-1.amazonaws.com"

echo "Deploying $SERVICE..."

# Map service → port
case $SERVICE in
  service-a) PORT=5000 ;;
  service-b) PORT=5001 ;;
  service-c) PORT=5002 ;;
  *) echo "Invalid service"; exit 1 ;;
esac

echo "Using port: $PORT"

# Login to ECR
aws ecr get-login-password --region ap-south-1 \
| docker login --username AWS --password-stdin $ECR_URL

# Pull latest image
docker pull $ECR_URL/$SERVICE:latest

# Stop old container
docker rm -f $SERVICE || true

# Run new container
docker run -d \
  --name $SERVICE \
  -p $PORT:5000 \
  --restart always \
  $ECR_URL/$SERVICE:latest

echo "Deployment completed 🚀"
