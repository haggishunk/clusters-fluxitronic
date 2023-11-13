# grafana agent resources

[https://grafana.com/docs/agent/latest/operator/deploy-agent-operator-resources/]()


## managing the agent and instances

The grafana agent depends on an operator and rbac to manage selected instances.

operator -> agent

agent -> metrics instances

agent -> logs instances


the instances take on the resources from the agent

other settings can be set at the instance or the agent


## use case 1

agent + instance + meta-monitoring

patch `GrafanaAgent.spec.metrics.externalLabels` with cluster

commonalize labels `GrafanaAgent.spec.metrics.instanceNamespaceSelector.matchLabels` with `MetricsInstance.metadata.labels`

commonalize labels `GrafanaAgent.spec.metrics.instanceSelector.matchLabels` with `MetricsInstance.metadata.labels` and `MetricsInstance.spec.podMonitor`

set meta-monitoring to use fixed label `app.kubernetes.io/name=grafana-agent`
