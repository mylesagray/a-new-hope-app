// External metrics API allows the HPA v2 to scale based on metrics coming from outside of Kubernetes cluster
// For more details on usage visit https://github.com/DirectXMan12/k8s-prometheus-adapter#quick-links

{
  _config+:: {
    prometheusAdapter+:: {
      namespace: $._config.namespace,
      // Rules for external-metrics
      config+:: {
        externalRules+: [
          {
            seriesQuery: 'aggregate_fps',
            seriesFilters: [],
            resources: {
              overrides: {
                kubernetes_namespace: {
                  resource: 'namespace'
                },
                kubernetes_pod: {
                  resource: 'pod'
                }
              },
            },
            name: {
              matches: '^(.*)_fps',
              as: "total_fps"
            },
            metricsQuery: 'avg_over_time(aggregate_fps[15s])'
          },
        ],
      },
    },
  },

  prometheusAdapter+:: {
    externalMetricsApiService: {
      apiVersion: 'apiregistration.k8s.io/v1',
      kind: 'APIService',
      metadata: {
        name: 'v1beta1.external.metrics.k8s.io',
      },
      spec: {
        service: {
          name: $.prometheusAdapter.service.metadata.name,
          namespace: $._config.prometheusAdapter.namespace,
        },
        group: 'external.metrics.k8s.io',
        version: 'v1beta1',
        insecureSkipTLSVerify: true,
        groupPriorityMinimum: 100,
        versionPriority: 100,
      },
    },
    externalMetricsClusterRoleServerResources: {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'ClusterRole',
      metadata: {
        name: 'external-metrics-server-resources',
      },
      rules: [{
        apiGroups: ['external.metrics.k8s.io'],
        resources: ['*'],
        verbs: ['*'],
      }],
    },
    externalMetricsClusterRoleBindingServerResources: {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'ClusterRoleBinding',
      metadata: {
        name: 'external-metrics-server-resources',
      },

      roleRef: {
        apiGroup: 'rbac.authorization.k8s.io',
        kind: 'ClusterRole',
        name: 'external-metrics-server-resources',
      },
      subjects: [{
        kind: 'ServiceAccount',
        name: $.prometheusAdapter.serviceAccount.metadata.name,
        namespace: $._config.prometheusAdapter.namespace,
      }],
    },
    externalMetricsClusterRoleBindingHPA: {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'ClusterRoleBinding',
      metadata: {
        name: 'hpa-controller-external-metrics',
      },

      roleRef: {
        apiGroup: 'rbac.authorization.k8s.io',
        kind: 'ClusterRole',
        name: 'external-metrics-server-resources',
      },
      subjects: [{
        kind: 'ServiceAccount',
        name: 'horizontal-pod-autoscaler',
        namespace: 'kube-system',
      }],
    },
  },
}