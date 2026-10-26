#!/usr/bin/env bash

set -eo pipefail

source .env

# Not the biggest fan, but for this simple example repo its ok
function replace_aws_account_id() {
    cp kubernetes/ethereum/geth.yaml "$temp_dir/geth.yaml"
    cp kubernetes/ethereum/prysm.yaml "$temp_dir/prysm.yaml"
    cp kubernetes/go-monitor/deployment.yaml "$temp_dir/deployment.yaml"

    sed -i.bu "s/<aws-account-id>/$AWS_ACCOUNT_ID/g" "$temp_dir/geth.yaml" "$temp_dir/prysm.yaml" "$temp_dir/deployment.yaml"
}

temp_dir="$(mktemp -d)"

replace_aws_account_id

kubectl apply -f kubernetes/miscellaneous/storageclass-blockchain-storage.yaml

kubectl apply -f kubernetes/ethereum/namespaces.yaml
kubectl apply -f kubernetes/ethereum/secrets.yaml
kubectl apply -f "$temp_dir/geth.yaml"
kubectl apply -f "$temp_dir/prysm.yaml"

kubectl apply -f kubernetes/go-monitor/namespace.yaml
kubectl apply -f kubernetes/go-monitor/configmap.yaml
kubectl apply -f "$temp_dir/deployment.yaml"

rm -rf "$temp_dir"