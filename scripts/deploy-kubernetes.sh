#!/usr/bin/env bash

set -eo pipefail

kubectl apply -f kubernetes/miscellaneous/storageclass-blockchain-storage.yaml

kubectl apply -f kubernetes/ethereum/namespaces.yaml
kubectl apply -f kubernetes/ethereum/secrets.yaml
kubectl apply -f kubernetes/ethereum/geth.yaml
kubectl apply -f kubernetes/ethereum/prysm.yaml

kubectl apply -f kubernetes/go-monitor/namespace.yaml
kubectl apply -f kubernetes/go-monitor/configmap.yaml
kubectl apply -f kubernetes/go-monitor/deployment.yaml