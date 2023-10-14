#!/usr/bin/env bash

set -eo pipefail

public_ip="$(curl -s https://v4.ident.me/)"
sed -i "s/<p2p-host-ip>/$public_ip/g" config.yaml

exec beacon-chain --config-file config.yaml