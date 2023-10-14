#!/usr/bin/env bash

set -eo pipefail

source .env

AWS_REGION="eu-central-1"

echo "building and pushing geth"
docker buildx build \
  --push \
  --platform linux/arm64 \
  -f docker/geth/Dockerfile \
  -t "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/poc/geth:v1.13.3" \
  .

echo "building and pushing prysm"
docker buildx build \
  --push \
  --platform linux/arm64 \
  -f docker/prysm/Dockerfile \
  -t "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/poc/prysm:v4.0.8" \
  .

echo "building and pushing go-monitor"
docker buildx build \
  --push \
  --platform linux/arm64 \
  -f go-monitor/build/Dockerfile \
  -t "$AWS_ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/poc/monitor:v1.0.0" \
  go-monitor