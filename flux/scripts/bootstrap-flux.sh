#!/bin/sh

# Bootstrap a target k8s cluster with flux
#
# This script is a wrapper around the standard `flux bootstrap github` command
# with some conventions to keep things consistent.
#
# Run this from within the repo under the branch you would like tracked and provide a cluster name.
#
# This script can be run idempotently with the beneficial side effect that
# if you have an upgraded flux cli locally it will update the cluster flux installation.
#
# Requires:
#
# - `GITHUB_TOKEN_FLUX`: a github token with repo privileges, preferably from a github machine user account for prod clusters
# - `GITHUB_AUTHOR_NAME`: a github username
# - `GITHUB_AUTHOR_EMAIL`: a github user email
#
# Usage:
#
# ./scripts/bootstrap-flux.sh <gke_cluster_name> [optional_kubectl_context]

k8s_cluster="$1"
if test -z "$k8s_cluster"; then
    echo "Set a cluster name k8s_cluster" && exit 1
else
    echo "Targeting cluster name: ${k8s_cluster}"
fi

k8s_context="${2:-$k8s_cluster}"
echo "Using local kubectl context: ${k8s_context}"
kubectl config use-context "${k8s_context}"

github_repo=$(basename "$(git rev-parse --show-toplevel)")
github_branch=$(git branch --show-current)
echo "Linking to remote source repo/branch: ${github_repo}/${github_branch}"

if test -n "$GITHUB_TOKEN_FLUX"; then
    export GITHUB_TOKEN="$GITHUB_TOKEN_FLUX"
else
    echo "Be sure to set GITHUB_TOKEN_FLUX with github repo privileges"
    exit 1
fi

if test -z "$GITHUB_AUTHOR_NAME" || test -z "$GITHUB_AUTHOR_NAME"; then
    echo "Be sure to set GITHUB_AUTHOR_NAME and GITHUB_AUTHOR_EMAIL linked to GITHUB_TOKEN_FLUX"
    exit 1
fi

flux bootstrap \
    github \
    --owner="$GITHUB_OWNER" \
    --repository="$github_repo" \
    --branch="$github_branch" \
    --path="flux/clusters/${k8s_cluster}" \
    --token-auth \
    --personal \
    --author-email "$GITHUB_AUTHOR_EMAIL" \
    --author-name "$GITHUB_AUTHOR_NAME" \
    --components-extra "image-reflector-controller,image-automation-controller"
