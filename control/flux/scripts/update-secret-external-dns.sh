#!/usr/bin/bash

set -feuo pipefail

SECRET_NAME=digitalocean-token
SECRET_KEY=digitalocean_api_token
DESTINATION_DIR=./infrastructure/clusters/gorgeous/external-dns

echo $DIGITALOCEAN_TOKEN_EXTERNAL_DNS \
    | tr -d '\n' \
    | kubectl create secret generic \
        $SECRET_NAME \
        -n default \
        --from-file=$SECRET_KEY=/dev/stdin \
        -oyaml \
        --dry-run=client > $DESTINATION_DIR/sops-secret.yaml

sops \
    --hc-vault-transit $VAULT_ADDR/v1/sops/keys/firstkey \
    --encrypt \
    --encrypted-regex '^(data|stringData)$' \
    --in-place $DESTINATION_DIR/sops-secret.yaml
