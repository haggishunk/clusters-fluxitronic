#!/usr/bin/env bash

# Diff local flux configs against a target k8s cluster with flux already installed
#
# This script is a wrapper around the standard `flux diff kustomization` command
# with some conventions to keep things consistent.
#
# Run this from within the repo under the branch you are developing and provide a cluster name.
#
# Usage:
#
# ./scripts/flux-diff-cluster.sh <gke_cluster_name>

cluster=$1
kubectl config use-context "$cluster"

for stack in infrastructure infra-services apps; do
    path="./${stack}/clusters/${cluster}"
    echo -e "\nComparing ${path} against ${stack}"
    flux diff kustomization --path "$path" "$stack"
done
