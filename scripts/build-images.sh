#!/usr/bin/env bash

set -eo pipefail

AWS_REGION="eu-central-1"

source .env

echo "logging into ECR"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "building and pushing geth"
docker buildx build \
  --push \
  --platform linux/arm64 \
  -f docker/geth/Dockerfile \
  -t "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ethereum-nodes-example/geth:v1.13.3" \
  .

echo "building and pushing prysm"
docker buildx build \
  --push \
  --platform linux/arm64 \
  -f docker/prysm/Dockerfile \
  -t "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ethereum-nodes-example/prysm:v4.0.8" \
  .

echo "building and pushing go-monitor"
docker buildx build \
  --push \
  --platform linux/arm64 \
  -f go-monitor/build/Dockerfile \
  -t "$AWS_ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/ethereum-nodes-example/monitor:v1.0.0" \
  go-monitor