# Kubernetes

__This Chart is under active development! We try to improve documentation and values consistency over time__

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Virtual Kubernetes Cluster

**Homepage:** <https://artifacthub.io/packages/helm/kvaps/kubernetes>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Bedag Informatik AG | <sre@bedag.ch> |  |

# Major Changes

Major Changes to functions are documented with the version affected. **Before upgrading the dependency version, check this section out!**

| **Change** | **Chart Version** | **Description** | **Commits/PRs** |
| :----------- | :---------------- | :--------------------- | :-------------- |
|||||

# Guides

# Components

## Machine Controller

## Operating System Manager

## Kubernetes

Installs the required components to provide a Kubernetes Control Plane (hosted in pods). The implementation is based on [Kuebrnetes by Kvaps](https://artifacthub.io/packages/helm/kvaps/kubernetes), who came uup with this great idea.

## Kubernetes Autoscaler

Based on [Cluster Autoscaler](https://github.com/kubernetes/autoscaler).
Allows to scale Kubernetes clusters based on the number of pods and nodes.
The component is deployed as a single deployment with a `controller` container. Since it's deployed on a hosting cluster, it's possible to downscale workers to zero and scale up again.

## GitOps

# Guides

## Exposure

### Admission

## ArgoCD Access

### Forwards the ArgoCD UI to your local machine

We must forward the ArgoCD within the new cluster in the kubectl client.
You can access the ArgoCD UI by running the following command:

```bash
# Execute Kubectl Container
kubectl exec -it test-cluster-kubectl sh -n machine-controller2

# Extract Admin Password
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# Forward ArgoCD UI
kubectl port-forward svc/argocd-server 8080:80 -n argocd
```

Open second terminal and run the following command:

```bash
kubectl port-forward pod/test-cluster-kubectl 9191:8080 -n machine-controller2
```

Access the ArgoCD UI by opening [http://localhost:9191]( http://localhost:9191) in your browser. Login with `admin` and previously extract password.

# Values

## Machine

Available Values for the [Machine Controller Component](). The component consists of a single deployment with a `controller` and `admission` container. Pod settings are therefor made for both subcomponents.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| machine.affinity | object | `{}` | Affinity |
| machine.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| machine.autoscaling.maxReplicas | int | `100` | Maximum available Replicas |
| machine.autoscaling.minReplicas | int | `1` | Minimum available Replicas |
| machine.autoscaling.targetCPUUtilizationPercentage | int | `80` | Benchmark CPU Usage |
| machine.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Benchmark Memory Usage |
| machine.component.ensureManifestsOnStartup | bool | `true` | Ensure all components manifests are present on controller start (as initContainer) |
| machine.component.removeManifestsOnDisable | bool | `true` | Remove all manifests on disable in the vcluster (**Attention**: When crds are deleted all crs will be deleted as well) |
| machine.imagePullSecrets | list | `[]` | Image pull Secrets |
| machine.kubelet.featureGates | list | `[]` | FeatureGates for kubelet |
| machine.metrics.service.annotations | object | `{}` | Service Annotations |
| machine.metrics.service.labels | object | `{}` | Service Labels |
| machine.metrics.serviceMonitor.annotations | object | `{}` | Assign additional Annotations |
| machine.metrics.serviceMonitor.enabled | bool | `true` | Enable ServiceMonitor |
| machine.metrics.serviceMonitor.endpoint.interval | string | `"15s"` | Set the scrape interval for the endpoint of the serviceMonitor |
| machine.metrics.serviceMonitor.endpoint.metricRelabelings | list | `[]` | Set metricRelabelings for the endpoint of the serviceMonitor |
| machine.metrics.serviceMonitor.endpoint.relabelings | list | `[]` | Set relabelings for the endpoint of the serviceMonitor |
| machine.metrics.serviceMonitor.endpoint.scrapeTimeout | string | `""` | Set the scrape timeout for the endpoint of the serviceMonitor |
| machine.metrics.serviceMonitor.jobSelector | string | `"app.kubernetes.io/name"` | Set JobLabel for the serviceMonitor |
| machine.metrics.serviceMonitor.labels | object | `{}` | Assign additional labels according to Prometheus' serviceMonitorSelector matching labels |
| machine.metrics.serviceMonitor.matchLabels | object | `{}` | Change matching labels |
| machine.metrics.serviceMonitor.namespace | string | `""` | Install the ServiceMonitor into a different Namespace, as the monitoring stack one (default: the release one) |
| machine.metrics.serviceMonitor.targetLabels | list | `[]` | Set targetLabels for the serviceMonitor |
| machine.nodeSelector | object | `{}` | Node Selector |
| machine.pause.image.digest | string | `""` | Image Digest |
| machine.pause.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| machine.pause.image.registry | string | `""` | Image registry |
| machine.pause.image.repository | string | `"pause"` | Image repository |
| machine.pause.image.tag | string | `"3.5"` | Image tag |
| machine.podAnnotations | object | `{}` | Pod Annotations |
| machine.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| machine.podLabels | object | `{}` | Pod Labels |
| machine.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":false,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| machine.priorityClassName | string | `""` | Pod PriorityClassName |
| machine.replicaCount | int | `1` | Replicas for Admission Pods |
| machine.runtime | string | `"containerd"` | Used Runtime |
| machine.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| machine.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| machine.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| machine.strategy | object | `{"rollingUpdate":{"maxUnavailable":"50%"},"type":"RollingUpdate"}` | Deployment Update Strategy |
| machine.tolerations | list | `[]` | Tolerations |
| machine.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| machine.version | string | `"v1.56.0"` | Tag Version used for machine-controller components |
| machine.volumes | list | `[]` | Volumes |

### Controller
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| machine.controller.args | object | `{"join-cluster-timeout":"25m","node-csr-approver":true,"worker-count":10}` | Controller Command Arguments ([See Available](https://github.com/kubermatic/machine-controller/blob/main/cmd/machine-controller/main.go)) |
| machine.controller.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| machine.controller.envsFrom | list | `[]` | Extra environment variables from |
| machine.controller.image.digest | string | `""` | Image Digest |
| machine.controller.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| machine.controller.image.registry | string | `"quay.io"` | Image registry |
| machine.controller.image.repository | string | `"kubermatic/machine-controller"` | Image repository |
| machine.controller.image.tag | string | `""` | Image tag (Version Overwrites) Overrides the image tag whose default is the chart appVersion. |
| machine.controller.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":8085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Livenessprobe configuration |
| machine.controller.readinessProbe | object | `{"httpGet":{"path":"/healthz","port":8085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Readinessprobe configuration |
| machine.controller.resources | object | `{}` | Resources configuration |
| machine.controller.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Security Context |
| machine.controller.volumeMounts | list | `[]` | Volume Mounts |

### Admission
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| machine.admission.args | object | `{"v":4}` | Webhook Command Arguments ([See Available](https://github.com/kubermatic/machine-controller/blob/main/cmd/webhook/main.go)) |
| machine.admission.enabled | bool | `true` | Enable Admission Webhook Feature |
| machine.admission.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| machine.admission.envsFrom | list | `[]` | Extra environment variables from |
| machine.admission.expose | string | `""` | How to expose the admission service to be reachable from the vcluster. Can be `ingress` or `loadbalancer |
| machine.admission.image.digest | string | `""` | Image Digest |
| machine.admission.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| machine.admission.image.registry | string | `"quay.io"` | Image registry |
| machine.admission.image.repository | string | `"kubermatic/machine-controller"` | Image repository |
| machine.admission.image.tag | string | `""` | Image tag (Version Overwrites) Overrides the image tag whose default is the chart appVersion. |
| machine.admission.ingress.annotations | object | `{}` | Annotations for admission ingress |
| machine.admission.ingress.contextPath | string | `"/admission/machine"` | Context path for admission ingress |
| machine.admission.ingress.ingressClassName | string | `""` | Ingressclass for all ingresses |
| machine.admission.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":9876,"scheme":"HTTPS"},"initialDelaySeconds":5,"periodSeconds":5}` | Livenessprobe configuration |
| machine.admission.readinessProbe | object | `{"httpGet":{"path":"/healthz","port":9876,"scheme":"HTTPS"},"periodSeconds":5}` | Readinessprobe configuration |
| machine.admission.resources | object | `{}` | Resources configuration |
| machine.admission.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Security Context |
| machine.admission.service.annotations | object | `{}` | Admission Service Annotations |
| machine.admission.service.labels | object | `{}` | Admission Service Labels |
| machine.admission.service.loadBalancerIP | string | `nil` | Admission Loadbalancer IP (must be set if `expose` is set to `loadbalancer`) |
| machine.admission.service.nodePort | string | `nil` | Admission nodePort |
| machine.admission.service.port | int | `9876` | Admission Service Port |
| machine.admission.service.type | string | `"ClusterIP"` | Admission Service Type |
| machine.admission.volumeMounts | list | `[]` | Volume Mounts |
| machine.admission.webhook.timeoutSeconds | int | `30` | Admission Webhook Timeout |
| machine.admission.webhook.tls.dnsNames | list | `[]` | Additional DNS Names for ADmission certificate |
| machine.admission.webhook.tls.ipAddresses | list | `[]` | Additional IP adresses for Admission certificate |
| machine.admission.webhook.tls.name | string | `""` | Override the TLS Secret Name |

## OSM

__This Component is not stable yet!__

Available Values for the [Operating System Manager](). The component consists of a single deployment with a `controller` and `admission` container. Pod settings are therefor made for both subcomponents.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| osm.affinity | object | `{}` | Affinity |
| osm.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| osm.autoscaling.maxReplicas | int | `100` | Maximum available Replicas |
| osm.autoscaling.minReplicas | int | `1` | Minimum available Replicas |
| osm.autoscaling.targetCPUUtilizationPercentage | int | `80` | Benchmark CPU Usage |
| osm.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Benchmark Memory Usage |
| osm.component.ensureManifestsOnStartup | bool | `true` | Ensure all components manifests are present on controller start (as initContainer) |
| osm.component.manageCRDs | bool | `true` | Manage CRDs within the cluster |
| osm.component.removeManifestsOnDisable | bool | `true` | Remove all manifests on disable in the vcluster (**Attention**: When crds are deleted all crs will be deleted as well) |
| osm.enabled | bool | `false` | Enable Operating System Manager Component |
| osm.imagePullSecrets | list | `[]` | Image pull Secrets |
| osm.metrics.enabled | bool | `true` | Enable Metrics |
| osm.metrics.service.annotations | object | `{}` | Service Annotations |
| osm.metrics.service.labels | object | `{}` | Service Labels |
| osm.metrics.serviceMonitor.annotations | object | `{}` | Assign additional Annotations |
| osm.metrics.serviceMonitor.enabled | bool | `true` | Enable ServiceMonitor |
| osm.metrics.serviceMonitor.endpoint.interval | string | `"15s"` | Set the scrape interval for the endpoint of the serviceMonitor |
| osm.metrics.serviceMonitor.endpoint.metricRelabelings | list | `[]` | Set metricRelabelings for the endpoint of the serviceMonitor |
| osm.metrics.serviceMonitor.endpoint.relabelings | list | `[]` | Set relabelings for the endpoint of the serviceMonitor |
| osm.metrics.serviceMonitor.endpoint.scrapeTimeout | string | `""` | Set the scrape timeout for the endpoint of the serviceMonitor |
| osm.metrics.serviceMonitor.jobLabel | string | `"app.kubernetes.io/name"` | Set JobLabel for the serviceMonitor |
| osm.metrics.serviceMonitor.labels | object | `{}` | Assign additional labels according to Prometheus' serviceMonitorSelector matching labels |
| osm.metrics.serviceMonitor.matchLabels | object | `{}` | Change matching labels |
| osm.metrics.serviceMonitor.namespace | string | `""` | Install the ServiceMonitor into a different Namespace, as the monitoring stack one (default: the release one) |
| osm.metrics.serviceMonitor.targetLabels | list | `[]` | Set targetLabels for the serviceMonitor |
| osm.nodeSelector | object | `{}` | Node Selector |
| osm.podAnnotations | object | `{}` | Pod Annotations |
| osm.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| osm.podLabels | object | `{}` | Pod Labels |
| osm.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":false,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| osm.priorityClassName | string | `""` | Pod PriorityClassName |
| osm.replicaCount | int | `1` | Replicas for Admission Pods |
| osm.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| osm.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| osm.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| osm.strategy | object | `{"rollingUpdate":{"maxUnavailable":"50%"},"type":"RollingUpdate"}` | Deployment Update Strategy |
| osm.tolerations | list | `[]` | Tolerations |
| osm.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| osm.version | string | `"v1.2.0"` | Tag Version used for both components |
| osm.volumes | list | `[]` | Volumes |

### Controller
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| osm.controller.args | object | `{"worker-count":10}` | Controller Command Arguments ([See Available](https://github.com/kubermatic/operating-system-manager/blob/main/cmd/osm-controller/main.go)) |
| osm.controller.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| osm.controller.envsFrom | list | `[]` | Extra environment variables from |
| osm.controller.image.digest | string | `""` | Image Digest |
| osm.controller.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| osm.controller.image.registry | string | `"quay.io"` | Image registry |
| osm.controller.image.repository | string | `"kubermatic/operating-system-manager"` | Image repository |
| osm.controller.image.tag | string | `""` | Image tag (Version Overwrites) Overrides the image tag whose default is the chart appVersion. |
| osm.controller.livenessProbe | object | `{"httpGet":{"path":"/readyz","port":8085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Livenessprobe configuration |
| osm.controller.readinessProbe | object | `{"httpGet":{"path":"/healthz","port":8085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Readinessprobe configuration |
| osm.controller.resources | object | `{}` | Pod Requests and limits |
| osm.controller.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Security Context |
| osm.controller.volumeMounts | list | `[]` | Pod VolumeMounts |

### Admission
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| osm.admission.args | object | `{"v":4}` | Webhook Command Arguments ([See Available](https://github.com/kubermatic/operating-system-manager/blob/main/cmd/webhook/main.go)) |
| osm.admission.enabled | bool | `true` | Enable Admission Webhook |
| osm.admission.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| osm.admission.envsFrom | list | `[]` | Extra environment variables from |
| osm.admission.expose | string | `""` | How to expose the admission service to be reachable from the vcluster. Can be `ingress` or `loadbalancer |
| osm.admission.image.digest | string | `""` | Image Digest |
| osm.admission.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| osm.admission.image.registry | string | `"quay.io"` | Image registry |
| osm.admission.image.repository | string | `"kubermatic/operating-system-manager"` | Image repository |
| osm.admission.image.tag | string | `""` | Image tag (Version Overwrites) Overrides the image tag whose default is the chart appVersion. |
| osm.admission.ingress.annotations | object | `{}` | Annotations for admission ingress |
| osm.admission.ingress.contextPath | string | `"/admission/osm"` | Context path for admission ingress |
| osm.admission.ingress.ingressClassName | string | `""` | Ingressclass for all ingresses |
| osm.admission.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":9085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Livenessprobe configuration |
| osm.admission.readinessProbe | object | `{"httpGet":{"path":"/healthz","port":9085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Readinessprobe configuration |
| osm.admission.resources | object | `{}` | Pod Requests and limits |
| osm.admission.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Security Context |
| osm.admission.service.annotations | object | `{}` | Admission Service Annotations |
| osm.admission.service.labels | object | `{}` | Admission Service Labels |
| osm.admission.service.loadBalancerIP | string | `nil` | Admission Loadbalancer IP (must be set if `expose` is set to `loadbalancer`) |
| osm.admission.service.nodePort | string | `nil` | Admission nodePort |
| osm.admission.service.port | int | `9877` | Admission Service Port |
| osm.admission.service.type | string | `"ClusterIP"` | Admission Service Type |
| osm.admission.volumeMounts | list | `[]` | Pod VolumeMounts |
| osm.admission.webhook.timeoutSeconds | int | `30` | Admission Webhook Timeout |
| osm.admission.webhook.tls.dnsNames | list | `[]` | Additional DNS Names for ADmission certificate |
| osm.admission.webhook.tls.ipAddresses | list | `[]` | Additional IP adresses for Admission certificate |
| osm.admission.webhook.tls.name | string | `""` | Override the TLS Secret Name |

## Autoscaler

Available Values for the [Autsocaler component]().

### Settings
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler.enabled | bool | `true` | Enable autsocaler component |
| autoscaler.expanderPriorities | object | `{}` | The expanderPriorities is used if `extraArgs.expander` contains `priority` and expanderPriorities is also set with the priorities. If `args.expander` contains `priority`, then expanderPriorities is used to define cluster-autoscaler-priority-expander priorities. See: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/expander/priority/readme.md |
| autoscaler.priorityConfigMapAnnotations | object | `{}` | Annotations to add to `cluster-autoscaler-priority-expander` ConfigMap. |

### Workload
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler.affinity | object | `{}` | Affinity |
| autoscaler.args | object | `{"leader-elect":true,"logtostderr":true,"scale-down-enabled":true,"stderrthreshold":"info","v":4}` | Additional container arguments. Refer to https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca for the full list of cluster autoscaler parameters and their default values. Everything after the first _ will be ignored allowing the use of multi-string arguments. |
| autoscaler.enabled | bool | `true` | Enable autsocaler component |
| autoscaler.envs | object | `{"CAPI_GROUP":"cluster.k8s.io"}` | Extra environment variables (`key: value` style, allows templating) |
| autoscaler.envsFrom | list | `[]` | Extra environment variables from |
| autoscaler.expanderPriorities | object | `{}` | The expanderPriorities is used if `extraArgs.expander` contains `priority` and expanderPriorities is also set with the priorities. If `args.expander` contains `priority`, then expanderPriorities is used to define cluster-autoscaler-priority-expander priorities. See: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/expander/priority/readme.md |
| autoscaler.image.digest | string | `""` | Image Digest |
| autoscaler.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| autoscaler.image.registry | string | `"k8s.gcr.io"` | Image registry |
| autoscaler.image.repository | string | `"autoscaling/cluster-autoscaler"` | Image repository |
| autoscaler.image.tag | string | `"v1.23.0"` | Image tag |
| autoscaler.imagePullSecrets | list | `[]` | Image pull Secrets |
| autoscaler.livenessProbe | object | `{"httpGet":{"path":"/health-check","port":8085},"initialDelaySeconds":5,"periodSeconds":5}` | Livenessprobe configuration |
| autoscaler.nodeSelector | object | `{}` | Node Selector |
| autoscaler.podAnnotations | object | `{}` | Pod Annotations |
| autoscaler.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| autoscaler.podLabels | object | `{}` | Pod Labels |
| autoscaler.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| autoscaler.priorityClassName | string | `""` | Pod PriorityClassName |
| autoscaler.priorityConfigMapAnnotations | object | `{}` | Annotations to add to `cluster-autoscaler-priority-expander` ConfigMap. |
| autoscaler.readinessProbe | object | `{"httpGet":{"path":"/health-check","port":8085},"periodSeconds":5}` | Readinessprobe configuration |
| autoscaler.replicaCount | int | `1` | Replicas for Admission Pods |
| autoscaler.resources | object | `{}` | Pod Requests and limits |
| autoscaler.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsUser":1001}` | Security Context |
| autoscaler.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| autoscaler.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| autoscaler.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| autoscaler.strategy | object | `{"rollingUpdate":{"maxUnavailable":1},"type":"RollingUpdate"}` | Deployment Update Strategy |
| autoscaler.tolerations | list | `[]` | Tolerations |
| autoscaler.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| autoscaler.volumes | list | `[]` | Volumes |

#### Autoscaling
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| autoscaler.autoscaling.maxReplicas | int | `100` | Maximum available Replicas |
| autoscaler.autoscaling.minReplicas | int | `1` | Minimum available Replicas |
| autoscaler.autoscaling.targetCPUUtilizationPercentage | int | `80` | Benchmark CPU Usage |
| autoscaler.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Benchmark Memory Usage |

#### Metrics
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler.metrics.serviceMonitor.annotations | object | `{}` | Assign additional Annotations |
| autoscaler.metrics.serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor |
| autoscaler.metrics.serviceMonitor.endpoint.interval | string | `"15s"` | Set the scrape interval for the endpoint of the serviceMonitor |
| autoscaler.metrics.serviceMonitor.endpoint.metricRelabelings | list | `[]` | Set metricRelabelings for the endpoint of the serviceMonitor |
| autoscaler.metrics.serviceMonitor.endpoint.relabelings | list | `[]` | Set relabelings for the endpoint of the serviceMonitor |
| autoscaler.metrics.serviceMonitor.endpoint.scrapeTimeout | string | `""` | Set the scrape timeout for the endpoint of the serviceMonitor |
| autoscaler.metrics.serviceMonitor.labels | object | `{}` | Assign additional labels according to Prometheus' serviceMonitorSelector matching labels |
| autoscaler.metrics.serviceMonitor.matchLabels | object | `{}` | Change matching labels |
| autoscaler.metrics.serviceMonitor.namespace | string | `""` | Install the ServiceMonitor into a different Namespace, as the monitoring stack one (default: the release one) |
| autoscaler.metrics.serviceMonitor.targetLabels | list | `[]` | Set targetLabels for the serviceMonitor |
