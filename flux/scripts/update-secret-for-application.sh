#!/usr/bin/bash

# create a sops encrypted k8s secret resource
# from an environment variable
#
# inputs:
#
# - environment variable
# - secret name
# - secret key
# - destination dir
# - vault address (optional)
# - vault transit key name (optional)
set -feuo pipefail

APPLICATION=$1

case $APPLICATION in
    external-secrets)
        SECRET_NAME=vault-approle-external-secrets
        SECRET_KEY=vault-token
        DESTINATION_DIR=./infra-services/clusters/gorgeous/external-secrets
        ;;

    cert-manager)
        SECRET_NAME=digitalocean-token
        SECRET_KEY=digitalocean_api_token
        DESTINATION_DIR=./infra-services/clusters/gorgeous/cert-manager
        ;;
    external-dns)
        SECRET_NAME=digitalocean-token
        SECRET_KEY=digitalocean_api_token
        DESTINATION_DIR=./infrastructure/clusters/gorgeous/external-dns
        ;;
    *)
        echo "$APPLICATION not supported" && exit 1
        ;;
esac

echo "Updating secret for application: ${APPLICATION}"

SECRET_FILE=$2

echo "Sourcing secret from file: ${SECRET_FILE}..."

cat "$SECRET_FILE" \
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
