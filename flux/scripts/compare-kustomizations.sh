#!/bin/bash

set -euo pipefail

TMP_DIR=$(mktemp -d)

KUST_1="$1"
KUST_2="$2"

trap '{ rm -rf $TMP_DIR ; exit 255; }' EXIT

kustomize build "$KUST_1" > "$TMP_DIR/manifest_1.yaml"
kustomize build "$KUST_2" > "$TMP_DIR/manifest_2.yaml"

git diff "$TMP_DIR/manifest_1.yaml" "$TMP_DIR/manifest_2.yaml"
