# general flux notifications package

This kustomize base contains a reusable set of resources configured to have info and error events sent to a provider, such as grafana, slack, or a generic webhook.

## requirements

Flux needs a secret to talk to providers which is different for each type of provider.  This package expects a google secret manager secret to exist with the base name of `flux-provider-secret`.  The name will be mutated based on any `namePrefix` or `nameSuffix` configured in the kustomize overlay.

## usage

Create an overlay sourcing this base, setting a name and adding some patches for the provider.

An example with grafana:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: flux-system
namePrefix: grafana-
resources:
- ../general
patches:
  - patch: |
      - op: replace
        path: /spec/type
        value: grafana
      - op: add
        path: /spec/address
        value: http://grafana.grafana/api/annotations
        create: true
    target:
      group: notification.toolkit.fluxcd.io
      version: v1beta2
      kind: Provider
```
