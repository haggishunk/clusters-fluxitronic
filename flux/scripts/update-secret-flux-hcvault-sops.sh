#!/usr/bin/bash

set -feuo pipefail

TOKEN=$(vault token create \
    -orphan \
    -policy=writer \
    -format json \
    | jq -r '.auth.client_token')

kubectl delete secret sops-hcvault \
           --namespace=flux-system \
           || /bin/true

echo "$TOKEN" | kubectl create secret generic sops-hcvault \
           --namespace=flux-system \
           --from-file=sops.vault-token=/dev/stdin
