# Vcluster

__This Chart is under active development! We try to improve documentation and values consistency over time__

![Version: 0.8.0](https://img.shields.io/badge/Version-0.8.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Virtual Kubernetes Cluster

**Homepage:** <https://artifacthub.io/packages/helm/kvaps/kubernetes>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Bedag Informatik AG | <sre@bedag.ch> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 2.14.1 |

# Major Changes

Major Changes to functions are documented with the version affected. **Before upgrading the dependency version, check this section out!**

| **Change** | **Chart Version** | **Description** | **Commits/PRs** |
| :----------- | :---------------- | :--------------------- | :-------------- |
|||||

## Guides

# Components

This chart contains different "components" (it's different tools which make up the control plane).
The purpose of the combination if these tools is to achieve a control plane, which is easy to manage and does not
relay on worker nodes to be managed. But we also do not intend to add a lot of complexity to the control plane.
All the components are deployed as pods in the hosting cluster and are toggled by the `enabled` flag.

## Kubernetes

Installs the required components to provide a Kubernetes Control Plane (hosted in pods). The implementation is based on [Kuebrnetes by Kvaps](https://artifacthub.io/packages/helm/kvaps/kubernetes), who came uup with this great idea.

## Machine Controller

__We recommend using our set version and configured flags__

The [Machine-Controller](https://github.com/kubermatic/machine-controller) by [Kubermatic](https://www.kubermatic.com/).

## Operating System Manager

__We recommend using our set version and configured flags. The component is not stable tested yet!__

The [Operating System Manager](https://github.com/kubermatic/operating-system-manager) by [Kubermatic](https://www.kubermatic.com/)  is responsible for creating and managing the required configurations for worker nodes in a Kubernetes cluster. It decouples operating system configurations into dedicated and isolable resources for better modularity and maintainability.
It's optional and only works together with [Machine Controller](#machine-controller). If you enable this component, we will take care of the configuration between Machine-Controller and Operating System Manager.

## Kubernetes

Installs the required components to provide a Kubernetes Control Plane (hosted in pods). The implementation is based on [Kuebrnetes by Kvaps](https://artifacthub.io/packages/helm/kvaps/kubernetes), who came uup with this great idea.

## Kubernetes Autoscaler

Based on [Cluster Autoscaler](https://github.com/kubernetes/autoscaler).
Allows to scale Kubernetes clusters based on the number of pods and nodes.
The component is deployed as a single deployment with a `controller` container. Since it's deployed on a hosting cluster, it's possible to downscale workers to zero and scale up again.

# Guides

## Exposure

### Admission

# Values

## Globals

---

Global Values
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.components.exposure.certificates.issuer.kind | string | `"Issuer"` | Set if the cert manager will generate either self-signed or CA signed SSL certificates. Its value will be either Issuer or ClusterIssuer |
| global.components.exposure.certificates.issuer.name | string | `""` | Set the name of the ClusterIssuer if issuer kind is ClusterIssuer and if cert manager will generate CA signed SSL certificates |
| global.components.exposure.certificates.issuer.selfSigned | bool | `true` | Creates self-signed Issuer |
| global.components.exposure.certificates.secretName | string | `""` | Uses Existing Secret for all certificates |
| global.components.exposure.expose | string | `"loadbalancer"` | Define how admission webhooks are expose (ingress or loadbalancer). Overwrites expose for all admission webhooks. |
| global.components.exposure.ingress.annotations | object | `{}` | Common annotations for admission ingresses |
| global.components.exposure.ingress.host | string | `"{{ include \"pkg.cluster.name\" $ }}.example.com"` | Host for admission ingresses (admission endpoints are exposed via path). supports templating |
| global.components.exposure.ingress.ingressClassName | string | `""` | Ingressclass for admission ingresses |
| global.components.exposure.ingress.port | int | `443` | Port for Ingresses |
| global.components.metrics | object | `{}` |  |
| global.components.networkPolicy.enabled | bool | `false` | Enable NetworkPolicies |
| global.components.networkPolicy.from | list | `[]` | Add `from` block for networkPolicies (by default from anywhere) |
| global.components.service.annotations | object | `{}` | Annotations for all services |
| global.components.service.labels | object | `{}` | Labels for all services |
| global.components.workloads.affinity | object | `{}` | Affinity for all workloads (Overwrites all workloads affinities) |
| global.components.workloads.annotations | object | `{}` | Annotations for all workloads (merged with workload annotations) |
| global.components.workloads.image.pullPolicy | string | `""` | Overwrites Pull Policy for all components |
| global.components.workloads.image.pullSecrets | list | `[]` | Additional image pull secrets for all components |
| global.components.workloads.labels | object | `{}` | Labels for all workloads (merged with workload labels) |
| global.components.workloads.nodeSelector | object | `{}` | Node Selector for all workloads (Overwrites all workloads nodeSelector) |
| global.components.workloads.podAnnotations | object | `{}` | Pod Annotations for all workloads (merged with workload podAnnotations) |
| global.components.workloads.podLabels | object | `{}` | Pod Labels for all workloads (merged with workload podLabels) |
| global.components.workloads.podSecurityContext | object | `{"enabled":false}` | Pod Security Context for all workloads  (Overwrites per workload podSecurityContext) |
| global.components.workloads.priorityClassName | string | `""` | Priority Class for all workloads (Overwrites all workloads priorityClassNames) |
| global.components.workloads.securityContext | object | `{"enabled":false}` | Container Security Context for all workloads (Overwrites per workload securityContext) |
| global.components.workloads.tolerations | list | `[]` | Tolerations for all workloads (Overwrites all workloads tolerations) |
| global.components.workloads.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads (Overwrites all workloads topologySpreadConstraints) |
| global.proxy.host | string | `""` | Proxy Host |
| global.proxy.no_proxy | string | `"10.0.0.0/8"` | No Proxy Hosts |
| global.registry.creds.password | string | `""` | Registry Password |
| global.registry.creds.username | string | `""` | Registry Username |
| global.registry.endpoint | string | `""` | Registry Endpoint |
| global.storageClassName | string | `""` | StorageClassName for all persistent volumes |

## Utilities Values

---
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cluster.name | string | The cluster name is derived from the `.Release.Name` | Define the cluster name |
| cluster.properties | object | `{}` | Properties are substituted into the gitops component |

## Lifecycle

---

We use a lifecycle Job/Cronjob to manage certain configurations within the vcluster and the hosting cluster.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lifecycle.argocd.namespace | string | `"argocd"` | Installation namespace of ArgoCD |
| lifecycle.argocd.rbac | bool | `true` | Creates required rbac in argoCD namespace to create cluster secrets |
| lifecycle.cilium.bgpControlPlane | object | `{"enabled":true}` | Enable BGP Control Plane feature |
| lifecycle.cilium.devices | string | `""` | Specify which network interfaces can run the eBPF datapath |
| lifecycle.cilium.enabled | bool | `true` | Install Cilium CNI |
| lifecycle.cilium.on_install | bool | `true` | Install only on chart install (First install) |
| lifecycle.cilium.version | string | `"1.9.18"` | Cilium version |
| lifecycle.cleanup.annotations | object | `{"helm.sh/hook":"pre-delete","helm.sh/hook-delete-policy":"before-hook-creation"}` | Job Annotations |
| lifecycle.cleanup.enabled | bool | `false` | Enable/Disable Cleanup |
| lifecycle.cleanup.labels | object | `{}` | Job Labels |
| lifecycle.current.extraManifests | object | See values.yaml | These manifests will be applied inside the cluster (supports templating) |
| lifecycle.current.extraManifestsOnInstall | object | See values.yaml | These manifests will be applied inside the cluster, but only on $.Release.Install and wont be touched again (supports templating) |
| lifecycle.jobs.affinity | object | `{}` | Affinity |
| lifecycle.jobs.extraEnv | list | `[]` | Additional Pod Environment variables |
| lifecycle.jobs.extraVolumeMounts | list | `[]` | Additional Pod VolumeMounts |
| lifecycle.jobs.extraVolumes | list | `[]` | Additional Pod Volumes |
| lifecycle.jobs.nodeSelector | object | `{}` | Node Selector |
| lifecycle.jobs.podAnnotations | object | `{}` | Pod Annotations |
| lifecycle.jobs.podLabels | object | `{}` | Pod Labels |
| lifecycle.jobs.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| lifecycle.jobs.priorityClassName | string | `""` | Pod PriorityClassName |
| lifecycle.jobs.resources | object | `{}` | Resources configuration |
| lifecycle.jobs.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"runAsGroup":20000,"runAsUser":20000}` | Container Security Context |
| lifecycle.jobs.tolerations | list | `[]` | Tolerations |
| lifecycle.jobs.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints |
| lifecycle.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| lifecycle.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| lifecycle.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| lifecycle.setup.annotations | object | `{"helm.sh/hook":"post-install,post-upgrade","helm.sh/hook-delete-policy":"before-hook-creation"}` | Job Annotations |
| lifecycle.setup.cronjob | bool | `true` | Deploy as Cronjob to run periodically |
| lifecycle.setup.failedJobsHistoryLimit | int | `3` | Cronjob failed jobs history limit |
| lifecycle.setup.injectProxy | bool | `true` | Inject Proxy as Environment Variables |
| lifecycle.setup.labels | object | `{}` | Job Labels |
| lifecycle.setup.schedule | string | `"0 0 1 */6 *"` | Cronjob Schedule |
| lifecycle.setup.successfulJobsHistoryLimit | int | `3` | Cronjob successful jobs history limit |
| lifecycle.setup.ttlSecondsAfterFinished | int | `120` | ttlSecondsAfterFinished for setup |
| lifecycle.vcluster.extraOnlineManifests | list | `[]` | List of URLs which will be applied inside the vcluster (supports templating) |
| lifecycle.vcluster.extraOnlineManifestsOnInstall | list | `[]` | List of URLs which will be applied inside the vcluster, but only on $.Release.Install and wont be touched again (supports templating) |

## Machine Values

---

Available Values for the [Machine Controller Component](#machine-controller). The component consists of a single deployment with a `controller` and `admission` container. Pod settings are therefor made for both subcomponents.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| machine.affinity | object | `{}` | Affinity |
| machine.annotations | object | `{}` | Annotations for Workload |
| machine.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| machine.autoscaling.maxReplicas | int | `100` | Maximum available Replicas |
| machine.autoscaling.minReplicas | int | `1` | Minimum available Replicas |
| machine.autoscaling.targetCPUUtilizationPercentage | int | `80` | Benchmark CPU Usage |
| machine.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Benchmark Memory Usage |
| machine.component.ensureManifestsOnStartup | bool | `true` | Ensure all components manifests are present on controller start (as initContainer) |
| machine.component.removeManifestsOnDisable | bool | `true` | Remove all manifests on disable in the vcluster (**Attention**: When crds are deleted all crs will be deleted as well) |
| machine.enabled | bool | `true` | Enable Machine-Controller Component |
| machine.imagePullSecrets | list | `[]` | Image pull Secrets |
| machine.kubelet.featureGates | list | `[]` | FeatureGates for kubelet |
| machine.labels | object | `{}` | Labels for Workload |
| machine.metrics.service.annotations | object | `{}` | Service Annotations |
| machine.metrics.service.labels | object | `{}` | Service Labels |
| machine.metrics.serviceMonitor.annotations | object | `{}` | Assign additional Annotations |
| machine.metrics.serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor |
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
| machine.version | string | `"v1.57.0"` | Tag Version used for machine-controller components |
| machine.volumes | list | `[]` | Volumes |

### Controller

---
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
| machine.controller.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| machine.controller.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":8085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Livenessprobe configuration |
| machine.controller.readinessProbe | object | `{"httpGet":{"path":"/healthz","port":8085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Readinessprobe configuration |
| machine.controller.resources | object | `{}` | Resources configuration |
| machine.controller.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Security Context |
| machine.controller.volumeMounts | list | `[]` | Volume Mounts |

### Admission

---
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| machine.admission.args | object | `{"v":4}` | Webhook Command Arguments ([See Available](https://github.com/kubermatic/machine-controller/blob/main/cmd/webhook/main.go)) |
| machine.admission.enabled | bool | `false` | Enable Admission Webhook Feature |
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
| machine.admission.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
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

## OSM Values

---

__This Component is not stable yet!__

Available Values for the [Operating System Manager](). The component consists of a single deployment with a `controller` and `admission` container. Pod settings are therefor made for both subcomponents.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| osm.affinity | object | `{}` | Affinity |
| osm.annotations | object | `{}` | Annotations for Workload |
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
| osm.labels | object | `{}` | Labels for Workload |
| osm.metrics.enabled | bool | `true` | Enable Metrics |
| osm.metrics.service.annotations | object | `{}` | Service Annotations |
| osm.metrics.service.labels | object | `{}` | Service Labels |
| osm.metrics.serviceMonitor.annotations | object | `{}` | Assign additional Annotations |
| osm.metrics.serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor |
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
| osm.version | string | `"v1.3.0"` | Tag Version used for both components |
| osm.volumes | list | `[]` | Volumes |

### Controller

---
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
| osm.controller.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| osm.controller.livenessProbe | object | `{"httpGet":{"path":"/readyz","port":8085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Livenessprobe configuration |
| osm.controller.readinessProbe | object | `{"httpGet":{"path":"/healthz","port":8085,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":5}` | Readinessprobe configuration |
| osm.controller.resources | object | `{}` | Pod Requests and limits |
| osm.controller.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Security Context |
| osm.controller.volumeMounts | list | `[]` | Pod VolumeMounts |

### Admission

---
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
| osm.admission.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
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

## Kubernetes Values

---

Available Values for the [Kubernetes component](#kubernetes).
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.controlPlane | object | `{"endpoint":null}` | ControlerPlaneEndpoint |
| kubernetes.controlPlane.endpoint | string | `nil` | Endpoint for ControlPlane (eg `128.1314.1234.4242:6443`). If not set, the vcluster will try to find the endpoint automatically. |
| kubernetes.enabled | bool | `true` | Enable Kubernetes Component |
| kubernetes.kubeProxy.enabled | bool | `true` | Install kube-proxy via KubeADM. If disabled, the cilium kube-proxy replacement will be used |
| kubernetes.version | string | `"v1.25.0"` | Version for API Server, Scheduler, Controller Manager (Tag for all kubernetes components) |

### API-Server

---

Deploys [Kubernetes API Server](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/).
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.apiServer.affinity | object | `{}` | Affinity |
| kubernetes.apiServer.annotations | object | `{}` | Annotations for Workload |
| kubernetes.apiServer.args | object | `{}` | Extra arguments for the kube-apiserver |
| kubernetes.apiServer.audit.enabled | bool | `false` | Enable Audit Log |
| kubernetes.apiServer.audit.maxAge | string | `"7"` | Defines the maximum number of days to retain old audit log files |
| kubernetes.apiServer.audit.maxBackup | string | `"2"` | Defines the maximum number of audit log files to retain |
| kubernetes.apiServer.audit.maxSize | string | `"100"` | Defines the maximum size in megabytes of the audit log file before it gets rotated |
| kubernetes.apiServer.audit.policy | string | `"# Log all requests at the Metadata level.\napiVersion: audit.k8s.io/v1\nkind: Policy\nrules:\n  - level: Metadata\n"` | Audit Policy |
| kubernetes.apiServer.audit.truncateEnabled | bool | `false` | Whether event and batch truncating is enabled |
| kubernetes.apiServer.audit.truncateMaxBatchSize | string | `"10485760"` | Maximum size in bytes of the batch sent to the underlying backend |
| kubernetes.apiServer.audit.truncateMaxEventSize | string | `"102400"` | Maximum size in bytes of the audit event sent to the underlying backend |
| kubernetes.apiServer.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| kubernetes.apiServer.autoscaling.maxReplicas | int | `5` | Maximum available Replicas |
| kubernetes.apiServer.autoscaling.minReplicas | int | `1` | Minimum available Replicas |
| kubernetes.apiServer.autoscaling.targetCPUUtilizationPercentage | int | `80` | Benchmark CPU Usage |
| kubernetes.apiServer.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Benchmark Memory Usage |
| kubernetes.apiServer.certSANs.dnsNames | list | `[]` | Additonal API-Server dns names for ETCD ceritifcate |
| kubernetes.apiServer.certSANs.ipAddresses | list | `[]` | Additonal API-Server adresses for ETCD ceritifcate |
| kubernetes.apiServer.enabled | bool | `true` | Enable Kubernetes API-Server |
| kubernetes.apiServer.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.apiServer.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.apiServer.image.digest | string | `""` | Image digest |
| kubernetes.apiServer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubernetes.apiServer.image.registry | string | `"registry.k8s.io"` | Image registry |
| kubernetes.apiServer.image.repository | string | `"kube-apiserver"` | Image repository |
| kubernetes.apiServer.image.tag | string | `""` | Image tag |
| kubernetes.apiServer.imagePullSecrets | list | `[]` | Image pull Secrets |
| kubernetes.apiServer.ingress.annotations | object | `{}` | Annotations for admission ingress |
| kubernetes.apiServer.ingress.contextPath | string | `"/admission/machine"` | Context path for admission ingress |
| kubernetes.apiServer.ingress.ingressClassName | string | `""` | Ingressclass for all ingresses |
| kubernetes.apiServer.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| kubernetes.apiServer.labels | object | `{}` | Labels for Workload |
| kubernetes.apiServer.metrics.probe.annotations | object | `{}` | Assign additional Annotations |
| kubernetes.apiServer.metrics.probe.enabled | bool | `false` | Enable Probe |
| kubernetes.apiServer.metrics.probe.interval | string | `""` | Probeing Interval |
| kubernetes.apiServer.metrics.probe.jobName | string | `""` | Name of the scrape_job |
| kubernetes.apiServer.metrics.probe.labels | object | `{}` | Assign additional labels according to Prometheus' probeSelector matching labels |
| kubernetes.apiServer.metrics.probe.module | string | `""` | Module to use for the probeing |
| kubernetes.apiServer.metrics.probe.namespace | string | `""` | Install the Probe into a different Namespace, as the monitoring stack one (default: the release one) |
| kubernetes.apiServer.metrics.probe.prober | object | `{"path":"","proxyUrl":"","scheme":"","url":""}` | Prober Configuration |
| kubernetes.apiServer.metrics.probe.prober.path | string | `""` | Prober path |
| kubernetes.apiServer.metrics.probe.prober.proxyUrl | string | `""` | Optional Proxy URL |
| kubernetes.apiServer.metrics.probe.prober.scheme | string | `""` | Scheme to use for Probing |
| kubernetes.apiServer.metrics.probe.prober.url | string | `""` | URL to the Prober |
| kubernetes.apiServer.metrics.probe.tlsConfig | object | `{}` | Probe tls Configuration |
| kubernetes.apiServer.metrics.service.annotations | object | `{}` | Service Annotations |
| kubernetes.apiServer.metrics.service.labels | object | `{}` | Service Labels |
| kubernetes.apiServer.networkPolicy.from | list | `[]` | Add `from` block for networkPolicies (by default from anywhere) |
| kubernetes.apiServer.nodeSelector | object | `{}` | Node Selector |
| kubernetes.apiServer.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.apiServer.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| kubernetes.apiServer.podLabels | object | `{}` | Pod Labels |
| kubernetes.apiServer.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| kubernetes.apiServer.port | int | `6443` | Port for API-Server |
| kubernetes.apiServer.priorityClassName | string | `""` | Pod PriorityClassName |
| kubernetes.apiServer.replicaCount | int | `2` | Replicas for API-Server |
| kubernetes.apiServer.resources | object | `{"requests":{"cpu":"100m","memory":"128Mi"}}` | Pod Requests and limits |
| kubernetes.apiServer.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Container Security Context |
| kubernetes.apiServer.service.enabled | bool | `true` | Enable API-Server Service |
| kubernetes.apiServer.strategy | object | `{"rollingUpdate":{"maxUnavailable":"30%"},"type":"RollingUpdate"}` | Deployment Update Strategy |
| kubernetes.apiServer.tolerations | list | `[]` | Tolerations |
| kubernetes.apiServer.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| kubernetes.apiServer.volumeMounts | list | `[]` | Additional volumemounts |
| kubernetes.apiServer.volumes | list | `[]` | Additional volumes |

### Controller Manager

---

Deploys [Kubernetes Controller Manager](https://kubernetes.io/docs/concepts/architecture/cloud-controller/).
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.controllerManager.affinity | object | `{}` | Affinity |
| kubernetes.controllerManager.annotations | object | `{}` | Annotations for Workload |
| kubernetes.controllerManager.args | object | `{}` | Extra arguments for the [controller-manager](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/) |
| kubernetes.controllerManager.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| kubernetes.controllerManager.autoscaling.maxReplicas | int | `5` | Maximum available Replicas |
| kubernetes.controllerManager.autoscaling.minReplicas | int | `1` | Minimum available Replicas |
| kubernetes.controllerManager.autoscaling.targetCPUUtilizationPercentage | int | `80` | Benchmark CPU Usage |
| kubernetes.controllerManager.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Benchmark Memory Usage |
| kubernetes.controllerManager.enabled | bool | `true` | Enable Kubernetes Controller-Manager |
| kubernetes.controllerManager.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.controllerManager.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.controllerManager.image.digest | string | `""` | Image Digest |
| kubernetes.controllerManager.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubernetes.controllerManager.image.registry | string | `"registry.k8s.io"` | Image registry |
| kubernetes.controllerManager.image.repository | string | `"kube-controller-manager"` | Image repository |
| kubernetes.controllerManager.image.tag | string | `""` | Image tag (Version Overwrites) Overrides the image tag whose default is the chart appVersion. |
| kubernetes.controllerManager.imagePullSecrets | list | `[]` | Image pull Secrets |
| kubernetes.controllerManager.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| kubernetes.controllerManager.labels | object | `{}` | Labels for Workload |
| kubernetes.controllerManager.nodeSelector | object | `{}` | Node Selector |
| kubernetes.controllerManager.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.controllerManager.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| kubernetes.controllerManager.podLabels | object | `{}` | Pod Labels |
| kubernetes.controllerManager.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| kubernetes.controllerManager.port | int | `10257` | Port for Controller-Manager |
| kubernetes.controllerManager.priorityClassName | string | `""` | Pod PriorityClassName |
| kubernetes.controllerManager.replicaCount | int | `2` | Replicas for Controller-Manager |
| kubernetes.controllerManager.resources | object | `{"requests":{"cpu":"100m","memory":"128Mi"}}` | Pod Requests and limits |
| kubernetes.controllerManager.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Container Security Context |
| kubernetes.controllerManager.service.annotations | object | `{}` | Service Annotations |
| kubernetes.controllerManager.service.enabled | bool | `true` | Enable Controller-Manager Service |
| kubernetes.controllerManager.service.labels | object | `{}` | Service Labels |
| kubernetes.controllerManager.service.loadBalancerIP | string | `nil` | LoadBalancerIP |
| kubernetes.controllerManager.service.port | int | `10257` | Service Port |
| kubernetes.controllerManager.service.type | string | `"ClusterIP"` | Service Type |
| kubernetes.controllerManager.strategy | object | `{"rollingUpdate":{"maxUnavailable":"50%"},"type":"RollingUpdate"}` | Deployment Update Strategy |
| kubernetes.controllerManager.tolerations | list | `[]` | Tolerations |
| kubernetes.controllerManager.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| kubernetes.controllerManager.volumeMounts | list | `[]` | Additional Volumemounts |
| kubernetes.controllerManager.volumes | list | `[]` | Additional Volumes |

### Scheduler

---

Deploys [Kubernetes Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/).
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.scheduler.affinity | object | `{}` | Affinity |
| kubernetes.scheduler.annotations | object | `{}` | Annotations for Workload |
| kubernetes.scheduler.args | object | `{}` | Extra arguments for the [scheduler](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/) |
| kubernetes.scheduler.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| kubernetes.scheduler.autoscaling.maxReplicas | int | `5` | Maximum available Replicas |
| kubernetes.scheduler.autoscaling.minReplicas | int | `1` | Minimum available Replicas |
| kubernetes.scheduler.autoscaling.targetCPUUtilizationPercentage | int | `80` | Benchmark CPU Usage |
| kubernetes.scheduler.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Benchmark Memory Usage |
| kubernetes.scheduler.configuration | object | `{}` | kube-scheduler configuration [Read More](https://kubernetes.io/docs/reference/scheduling/config/) |
| kubernetes.scheduler.enabled | bool | `true` | Enable Kubernetes Scheduler |
| kubernetes.scheduler.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.scheduler.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.scheduler.image.digest | string | `""` | Image Digest |
| kubernetes.scheduler.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubernetes.scheduler.image.registry | string | `"registry.k8s.io"` | Image registry |
| kubernetes.scheduler.image.repository | string | `"kube-scheduler"` | Image repository |
| kubernetes.scheduler.image.tag | string | `""` | Image tag (Version Overwrites) Overrides the image tag whose default is the chart appVersion. |
| kubernetes.scheduler.imagePullSecrets | list | `[]` | Image pull Secrets |
| kubernetes.scheduler.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| kubernetes.scheduler.labels | object | `{}` | Labels for Workload |
| kubernetes.scheduler.metrics.service.annotations | object | `{}` | Service Annotations |
| kubernetes.scheduler.metrics.service.labels | object | `{}` | Service Labels |
| kubernetes.scheduler.metrics.serviceMonitor.annotations | object | `{}` | Assign additional Annotations |
| kubernetes.scheduler.metrics.serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor |
| kubernetes.scheduler.metrics.serviceMonitor.endpoint.interval | string | `"15s"` | Set the scrape interval for the endpoint of the serviceMonitor |
| kubernetes.scheduler.metrics.serviceMonitor.endpoint.metricRelabelings | list | `[]` | Set metricRelabelings for the endpoint of the serviceMonitor |
| kubernetes.scheduler.metrics.serviceMonitor.endpoint.relabelings | list | `[]` | Set relabelings for the endpoint of the serviceMonitor |
| kubernetes.scheduler.metrics.serviceMonitor.endpoint.scrapeTimeout | string | `""` | Set the scrape timeout for the endpoint of the serviceMonitor |
| kubernetes.scheduler.metrics.serviceMonitor.jobSelector | string | `"app.kubernetes.io/name"` | Set JobLabel for the serviceMonitor |
| kubernetes.scheduler.metrics.serviceMonitor.labels | object | `{}` | Assign additional labels according to Prometheus' serviceMonitorSelector matching labels |
| kubernetes.scheduler.metrics.serviceMonitor.matchLabels | object | `{}` | Change matching labels |
| kubernetes.scheduler.metrics.serviceMonitor.namespace | string | `""` | Install the ServiceMonitor into a different Namespace, as the monitoring stack one (default: the release one) |
| kubernetes.scheduler.metrics.serviceMonitor.targetLabels | list | `[]` | Set targetLabels for the serviceMonitor |
| kubernetes.scheduler.nodeSelector | object | `{}` | Node Selector |
| kubernetes.scheduler.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.scheduler.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| kubernetes.scheduler.podLabels | object | `{}` | Pod Labels |
| kubernetes.scheduler.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| kubernetes.scheduler.port | int | `10259` | Port for kube-scheduler |
| kubernetes.scheduler.priorityClassName | string | `""` | Pod PriorityClassName |
| kubernetes.scheduler.replicaCount | int | `2` | Replicas for kube-scheduler |
| kubernetes.scheduler.resources | object | `{"requests":{"cpu":"100m","memory":"128Mi"}}` | Pod Requests and limits |
| kubernetes.scheduler.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Container Security Context |
| kubernetes.scheduler.service.annotations | object | `{}` | Service Annotations |
| kubernetes.scheduler.service.enabled | bool | `true` | Enable kube-scheduler Service |
| kubernetes.scheduler.service.labels | object | `{}` | Service Labels |
| kubernetes.scheduler.service.loadBalancerIP | string | `nil` | LoadBalancerIP |
| kubernetes.scheduler.service.port | int | `10259` | Service Port |
| kubernetes.scheduler.service.type | string | `"ClusterIP"` | Service Type |
| kubernetes.scheduler.strategy | object | `{"rollingUpdate":{"maxUnavailable":"50%"},"type":"RollingUpdate"}` | Deployment Update Strategy |
| kubernetes.scheduler.tolerations | list | `[]` | Tolerations |
| kubernetes.scheduler.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| kubernetes.scheduler.volumeMounts | list | `[]` | Additional Volumemounts |
| kubernetes.scheduler.volumes | list | `[]` | Additional Volumes |

### ETCD

---

Deploys [ETCD](https://etcd.io/).
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.etcd.affinity | object | `{}` | Affinity |
| kubernetes.etcd.annotations | object | `{}` | Annotations for Workload |
| kubernetes.etcd.args | object | `{"snapshot-count":10000}` | Extra arguments for ETCD |
| kubernetes.etcd.certSANs.dnsNames | list | `[]` | Additonal DNS names for ETCD ceritifcate |
| kubernetes.etcd.certSANs.ipAddresses | list | `[]` | Additonal IP adresses names for ETCD ceritifcate |
| kubernetes.etcd.enabled | bool | `true` | Enable ETCD |
| kubernetes.etcd.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.etcd.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.etcd.image.digest | string | `""` | Image Digest |
| kubernetes.etcd.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubernetes.etcd.image.registry | string | `"registry.k8s.io"` | Image registry |
| kubernetes.etcd.image.repository | string | `"etcd"` | Image repository |
| kubernetes.etcd.image.tag | string | `"3.5.7-0"` | Image tag |
| kubernetes.etcd.imagePullSecrets | list | `[]` | Image pull Secrets |
| kubernetes.etcd.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| kubernetes.etcd.labels | object | `{}` | Labels for Workload |
| kubernetes.etcd.metrics.service.annotations | object | `{}` | Service Annotations |
| kubernetes.etcd.metrics.service.labels | object | `{}` | Service Labels |
| kubernetes.etcd.metrics.serviceMonitor.annotations | object | `{}` | Assign additional Annotations |
| kubernetes.etcd.metrics.serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor |
| kubernetes.etcd.metrics.serviceMonitor.endpoint.interval | string | `"15s"` | Set the scrape interval for the endpoint of the serviceMonitor |
| kubernetes.etcd.metrics.serviceMonitor.endpoint.metricRelabelings | list | `[]` | Set metricRelabelings for the endpoint of the serviceMonitor |
| kubernetes.etcd.metrics.serviceMonitor.endpoint.relabelings | list | `[]` | Set relabelings for the endpoint of the serviceMonitor |
| kubernetes.etcd.metrics.serviceMonitor.endpoint.scrapeTimeout | string | `""` | Set the scrape timeout for the endpoint of the serviceMonitor |
| kubernetes.etcd.metrics.serviceMonitor.jobSelector | string | `"app.kubernetes.io/name"` | Set JobLabel for the serviceMonitor |
| kubernetes.etcd.metrics.serviceMonitor.labels | object | `{}` | Assign additional labels according to Prometheus' serviceMonitorSelector matching labels |
| kubernetes.etcd.metrics.serviceMonitor.matchLabels | object | `{}` | Change matching labels |
| kubernetes.etcd.metrics.serviceMonitor.namespace | string | `""` | Install the ServiceMonitor into a different Namespace, as the monitoring stack one (default: the release one) |
| kubernetes.etcd.metrics.serviceMonitor.targetLabels | list | `[]` | Set targetLabels for the serviceMonitor |
| kubernetes.etcd.minReadySeconds | int | `10` | Minimum ready seconds |
| kubernetes.etcd.nodeSelector | object | `{}` | Node Selector |
| kubernetes.etcd.persistence.accessModes | list | `["ReadWriteOnce"]` | Access Modes for ETCD |
| kubernetes.etcd.persistence.annotations | object | `{"helm.sh/resource-policy":"keep"}` | Annotations for ETCD |
| kubernetes.etcd.persistence.enabled | bool | `true` | Enable Persistence for ETCD |
| kubernetes.etcd.persistence.finalizers | list | `["kubernetes.io/pvc-protection"]` | Finalizers for ETCD |
| kubernetes.etcd.persistence.size | string | `"1Gi"` | Size for ETCD |
| kubernetes.etcd.persistence.storageClassName | string | `""` | Storage Class for ETCD |
| kubernetes.etcd.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.etcd.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| kubernetes.etcd.podLabels | object | `{}` | Pod Labels |
| kubernetes.etcd.podManagementPolicy | string | `"OrderedReady"` | Pod Management Policy |
| kubernetes.etcd.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| kubernetes.etcd.ports.client | int | `2379` | ETCD Client Port |
| kubernetes.etcd.ports.metrics | int | `2381` | ETCD Metrics Port |
| kubernetes.etcd.ports.peer | int | `2380` | ETCD Peer Port |
| kubernetes.etcd.priorityClassName | string | `""` | Pod PriorityClassName |
| kubernetes.etcd.replicaCount | int | `3` | Replicas for ETCD Pods |
| kubernetes.etcd.resources | object | `{"requests":{"cpu":"100m","memory":"128Mi"}}` | Pod Requests and limits |
| kubernetes.etcd.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Container Security Context |
| kubernetes.etcd.tolerations | list | `[]` | Tolerations |
| kubernetes.etcd.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| kubernetes.etcd.updateStrategy | object | `{}` | Update Strategy |
| kubernetes.etcd.volumeMounts | list | `[]` | Additional volumemounts |
| kubernetes.etcd.volumes | list | `[]` | Additional volumes |

#### ETCD Backup

---

Scheduled snapshots of ETCD via Cronjob.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.etcd.backup.affinity | object | `{}` | Affinity |
| kubernetes.etcd.backup.annotations | object | `{}` | Annotations for Workload |
| kubernetes.etcd.backup.args | object | `{}` | Extra arguments for ETCD Backup |
| kubernetes.etcd.backup.enabled | bool | `false` | Enable ETCD Backup |
| kubernetes.etcd.backup.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.etcd.backup.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.etcd.backup.failedJobsHistoryLimit | int | `3` | Failed Jobs History Limit for ETCD Backup |
| kubernetes.etcd.backup.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| kubernetes.etcd.backup.labels | object | `{}` | Labels for Workload |
| kubernetes.etcd.backup.nodeSelector | object | `{}` | Node Selector |
| kubernetes.etcd.backup.persistence.accessModes | list | `["ReadWriteOnce"]` | Access Modes for ETCD Backup |
| kubernetes.etcd.backup.persistence.annotations | object | `{"helm.sh/resource-policy":"keep"}` | Annotations for ETCD Backup |
| kubernetes.etcd.backup.persistence.existingClaim | string | `""` | Use existing claim for ETCD Backup |
| kubernetes.etcd.backup.persistence.finalizers | list | `["kubernetes.io/pvc-protection"]` | Finalizers for ETCD Backup |
| kubernetes.etcd.backup.persistence.mountOnETCD | bool | `false` | Mounts backup volume on etcd pods (Recommended if accessModes is ReadWriteMany) |
| kubernetes.etcd.backup.persistence.size | string | `"1Gi"` | Size for ETCD Backup |
| kubernetes.etcd.backup.persistence.storageClassName | string | `""` | Storage Class for ETCD Backup |
| kubernetes.etcd.backup.persistence.subPath | string | `""` | Subpath for ETCD Backup |
| kubernetes.etcd.backup.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.etcd.backup.podLabels | object | `{}` | Pod Labels |
| kubernetes.etcd.backup.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| kubernetes.etcd.backup.priorityClassName | string | `""` | Pod PriorityClassName |
| kubernetes.etcd.backup.resources | object | `{}` | Pod Requests and limits |
| kubernetes.etcd.backup.restartPolicy | string | `"OnFailure"` | Restart Policy for ETCD Backup |
| kubernetes.etcd.backup.schedule | string | `"0 */12 * * *"` | Schedule for ETCD Backup |
| kubernetes.etcd.backup.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Container Security Context |
| kubernetes.etcd.backup.successfulJobsHistoryLimit | int | `3` | Successful Jobs History Limit for ETCD Backup |
| kubernetes.etcd.backup.tolerations | list | `[]` | Tolerations |
| kubernetes.etcd.backup.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| kubernetes.etcd.backup.ttlSecondsAfterFinished | int | `120` | ttlSecondsAfterFinished for ETCD Backup |
| kubernetes.etcd.backup.volumeMounts | list | `[]` | Additional volumemounts |
| kubernetes.etcd.backup.volumes | list | `[]` | Additional volumes |

### Konnektivity

---

Konnectivity is required to establish a connection to the API Server from the cluster network. [Read More about it](https://kubernetes.io/docs/tasks/extend-kubernetes/setup-konnectivity/). The following values are available for both Konnectivity Components:
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.konnectivity.enabled | bool | `true` | En/Disable konnectivity-server and konnectivity-agent |
| kubernetes.konnectivity.version | string | `""` | Set version for both konnectivity-server and konnectivity-agent |

#### Server

---

The Konnectivity-Server is deployed alongside with the API-Server. It must be reachable for the Konnectivity-Agent.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.konnectivity.server.affinity | object | `{}` | Affinity |
| kubernetes.konnectivity.server.annotations | object | `{}` | Annotations for Workload |
| kubernetes.konnectivity.server.args | object | `{}` | Konnectivity Server extra arguments |
| kubernetes.konnectivity.server.enabled | bool | `true` | Enable Konnectivity Server |
| kubernetes.konnectivity.server.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.konnectivity.server.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.konnectivity.server.image.digest | string | `""` | Image Digest |
| kubernetes.konnectivity.server.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubernetes.konnectivity.server.image.registry | string | `"registry.k8s.io"` | Image registry |
| kubernetes.konnectivity.server.image.repository | string | `"kas-network-proxy/proxy-server"` | Image repository |
| kubernetes.konnectivity.server.image.tag | string | `"v0.0.37"` | Image tag |
| kubernetes.konnectivity.server.imagePullSecrets | list | `[]` | Image pull Secrets |
| kubernetes.konnectivity.server.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| kubernetes.konnectivity.server.labels | object | `{}` | Labels for Workload |
| kubernetes.konnectivity.server.mode | string | `"GRPC"` | This controls the protocol between the API Server and the Konnectivity server. Supported values are "GRPC" and "HTTPConnect". "GRPC" will deploy konnectivity-server as a sidecar for apiserver. "HTTPConnect" will deploy konnectivity-server as separate deployment. |
| kubernetes.konnectivity.server.networkPolicy.from | list | `[]` | Add `from` block for networkPolicies (by default from anywhere) |
| kubernetes.konnectivity.server.nodeSelector | object | `{}` | Node Selector |
| kubernetes.konnectivity.server.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.konnectivity.server.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| kubernetes.konnectivity.server.podLabels | object | `{}` | Pod Labels |
| kubernetes.konnectivity.server.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context (only used in HTTPConnect mode) |
| kubernetes.konnectivity.server.priorityClassName | string | `""` | Pod PriorityClassName |
| kubernetes.konnectivity.server.replicaCount | int | `2` | Konnectivity Server Replicas (only used in HTTPConnect mode) |
| kubernetes.konnectivity.server.resources | object | `{"requests":{"cpu":"100m","memory":"128Mi"}}` | Konnectivity Server resources |
| kubernetes.konnectivity.server.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["all"]},"enabled":true,"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsUser":65534}` | Container Security Context |
| kubernetes.konnectivity.server.sidecar | bool | `true` | Enable Konnectivity Server as sidecfar for API Server |
| kubernetes.konnectivity.server.strategy | object | `{"rollingUpdate":{"maxUnavailable":"50%"},"type":"RollingUpdate"}` | Deployment Update Strategy |
| kubernetes.konnectivity.server.tolerations | list | `[]` | Tolerations |
| kubernetes.konnectivity.server.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| kubernetes.konnectivity.server.volumeMounts | list | `[]` | Additional Volumemounts |
| kubernetes.konnectivity.server.volumes | list | `[]` | Additional Volumes |

#### Agent (In-Cluster)

---

The konnectivity-Agent is deployed inside the vcluster and should establish a connection to the Konnectivity-Server. We recommend running the Konnectivity-Agent as Daemonset.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.konnectivity.agent.affinity | object | `{}` | Affinity |
| kubernetes.konnectivity.agent.annotations | object | `{}` | Annotations for Workload |
| kubernetes.konnectivity.agent.args | object | `{}` | Konnectivity Agent extra arguments |
| kubernetes.konnectivity.agent.enabled | bool | `false` | Enable Konnectivity Agent |
| kubernetes.konnectivity.agent.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.konnectivity.agent.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.konnectivity.agent.hostNetwork | bool | `false` | Use HostNetwork |
| kubernetes.konnectivity.agent.image.digest | string | `""` | Image Digest |
| kubernetes.konnectivity.agent.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubernetes.konnectivity.agent.image.registry | string | `"registry.k8s.io"` | Image registry |
| kubernetes.konnectivity.agent.image.repository | string | `"kas-network-proxy/proxy-agent"` | Image repository |
| kubernetes.konnectivity.agent.image.tag | string | `"v0.0.37"` | Image tag (Version Overwrites) Overrides the image tag whose default is the chart appVersion. |
| kubernetes.konnectivity.agent.imagePullSecrets | list | `[]` | Image pull Secrets |
| kubernetes.konnectivity.agent.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| kubernetes.konnectivity.agent.labels | object | `{}` | Labels for Workload |
| kubernetes.konnectivity.agent.nodeSelector | object | `{}` | Node Selector |
| kubernetes.konnectivity.agent.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.konnectivity.agent.podLabels | object | `{}` | Pod Labels |
| kubernetes.konnectivity.agent.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| kubernetes.konnectivity.agent.ports.admin | int | `8133` | Konnectivity Agent Administration Port |
| kubernetes.konnectivity.agent.ports.health | int | `8134` | Konnectivity Agent Health Port |
| kubernetes.konnectivity.agent.priorityClassName | string | `"system-cluster-critical"` | Pod PriorityClassName |
| kubernetes.konnectivity.agent.replicaCount | int | `2` | Replicas for admin (only for type `Deployment`) |
| kubernetes.konnectivity.agent.resources | object | `{"requests":{"cpu":"100m","memory":"128Mi"}}` | Pod Requests and limits |
| kubernetes.konnectivity.agent.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["all"]},"enabled":true,"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsUser":65534}` | Container Security Context |
| kubernetes.konnectivity.agent.strategy | object | `{"rollingUpdate":{"maxUnavailable":"50%"},"type":"RollingUpdate"}` | Deployment Update Strategy (Or DaemonSet Update Strategy) |
| kubernetes.konnectivity.agent.tolerations | list | `[{"key":"CriticalAddonsOnly","operator":"Exists"}]` | Tolerations |
| kubernetes.konnectivity.agent.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| kubernetes.konnectivity.agent.type | string | `"DaemonSet"` | Can be `DaemonSet` or `Deployment` |

### Admin

---

Deploys an administration pod which has the admin kubeconfig mounted and allows for easy access to the cluster.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.admin.affinity | object | `{}` | Affinity |
| kubernetes.admin.annotations | object | `{}` | Annotations for Workload |
| kubernetes.admin.enabled | bool | `true` | Enable Kubernetes Administration |
| kubernetes.admin.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.admin.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.admin.image.digest | string | `""` | Image Digest |
| kubernetes.admin.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubernetes.admin.image.registry | string | `"ghcr.io"` | Image registry |
| kubernetes.admin.image.repository | string | `"kvaps/kubernetes-tools"` | Image repository |
| kubernetes.admin.image.tag | string | `"v0.13.4"` | Image tag (Version Overwrites) Overrides the image tag whose default is the chart appVersion. |
| kubernetes.admin.image.use_jobs | bool | `true` | Use the Job Image (used for kubectl admin and kubeadmin bootstrap) |
| kubernetes.admin.imagePullSecrets | list | `[]` | Image pull Secrets |
| kubernetes.admin.injectProxy | bool | `true` | Inject Proxy as Environment Variables |
| kubernetes.admin.labels | object | `{}` | Labels for Workload |
| kubernetes.admin.nodeSelector | object | `{}` | Node Selector |
| kubernetes.admin.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.admin.podDisruptionBudget | object | `{}` | Configure PodDisruptionBudget |
| kubernetes.admin.podLabels | object | `{}` | Pod Labels |
| kubernetes.admin.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| kubernetes.admin.priorityClassName | string | `""` | Pod PriorityClassName |
| kubernetes.admin.replicaCount | int | `1` | Replicas for admin |
| kubernetes.admin.resources | object | `{"requests":{"cpu":"100m","memory":"128Mi"}}` | Pod Requests and limits |
| kubernetes.admin.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["all"]},"enabled":true,"readOnlyRootFilesystem":false}` | Container Security Context |
| kubernetes.admin.strategy | object | `{}` | Deployment Update Strategy |
| kubernetes.admin.tolerations | list | `[]` | Tolerations |
| kubernetes.admin.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |
| kubernetes.admin.volumeMounts | list | `[]` | Additional Volumemounts |
| kubernetes.admin.volumes | list | `[]` | Additional Volumes |

### CoreDNS (In-Cluster)

---
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetes.coredns.affinity | object | `{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"k8s-app","operator":"In","values":["kube-dns"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}` | Affinity |
| kubernetes.coredns.annotations | object | `{}` | Annotations for Workload |
| kubernetes.coredns.enabled | bool | `true` | Install CoreDNS via KubeADM |
| kubernetes.coredns.envs | object | `{}` | Extra environment variables (`key: value` style, allows templating) |
| kubernetes.coredns.envsFrom | list | `[]` | Extra environment variables from |
| kubernetes.coredns.image.digest | string | `""` | Image Digest |
| kubernetes.coredns.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubernetes.coredns.image.registry | string | `nil` | Image registry |
| kubernetes.coredns.image.repository | string | `"coredns/coredns"` | Image repository |
| kubernetes.coredns.image.tag | string | `"1.10.0"` | Image tag |
| kubernetes.coredns.imagePullSecrets | list | `[]` | Image pull Secrets |
| kubernetes.coredns.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| kubernetes.coredns.labels | object | `{}` | Labels for Workload |
| kubernetes.coredns.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node Selector |
| kubernetes.coredns.podAnnotations | object | `{}` | Pod Annotations |
| kubernetes.coredns.podLabels | object | `{}` | Pod Labels |
| kubernetes.coredns.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":false,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod Security Context |
| kubernetes.coredns.priorityClassName | string | `"system-cluster-critical"` | Pod PriorityClassName |
| kubernetes.coredns.replicaCount | int | `2` | CoreDNS Replicas |
| kubernetes.coredns.resources | object | `{"limits":{"memory":"170Mi"},"requests":{"cpu":"100m","memory":"70Mi"}}` | CoreDNS resources |
| kubernetes.coredns.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":["NET_BIND_SERVICE"],"drop":["all"]},"enabled":true,"readOnlyRootFilesystem":true}` | Container Security Context |
| kubernetes.coredns.strategy | object | `{"rollingUpdate":{"maxUnavailable":1},"type":"RollingUpdate"}` | Deployment Update Strategy |
| kubernetes.coredns.tolerations | list | `[{"key":"CriticalAddonsOnly","operator":"Exists"}]` | Tolerations |
| kubernetes.coredns.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints for all workloads |

## Autoscaler Values

Available Values for the [Autsocaler component](#autoscaler).

### Settings

---
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler.enabled | bool | `false` | Enable autsocaler component |
| autoscaler.expanderPriorities | object | `{}` | The expanderPriorities is used if `extraArgs.expander` contains `priority` and expanderPriorities is also set with the priorities. If `args.expander` contains `priority`, then expanderPriorities is used to define cluster-autoscaler-priority-expander priorities. See: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/expander/priority/readme.md |
| autoscaler.priorityConfigMapAnnotations | object | `{}` | Annotations to add to `cluster-autoscaler-priority-expander` ConfigMap. |

### Workload

---
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler.affinity | object | `{}` | Affinity |
| autoscaler.annotations | object | `{}` | Annotations for Workload |
| autoscaler.args | object | `{"leader-elect":true,"logtostderr":true,"scale-down-enabled":true,"stderrthreshold":"info","v":4}` | Additional container arguments. Refer to https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca for the full list of cluster autoscaler parameters and their default values. Everything after the first _ will be ignored allowing the use of multi-string arguments. |
| autoscaler.enabled | bool | `false` | Enable autsocaler component |
| autoscaler.envs | object | `{"CAPI_GROUP":"cluster.k8s.io"}` | Extra environment variables (`key: value` style, allows templating) |
| autoscaler.envsFrom | list | `[]` | Extra environment variables from |
| autoscaler.expanderPriorities | object | `{}` | The expanderPriorities is used if `extraArgs.expander` contains `priority` and expanderPriorities is also set with the priorities. If `args.expander` contains `priority`, then expanderPriorities is used to define cluster-autoscaler-priority-expander priorities. See: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/expander/priority/readme.md |
| autoscaler.image.digest | string | `""` | Image Digest |
| autoscaler.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| autoscaler.image.registry | string | `"registry.k8s.io"` | Image registry |
| autoscaler.image.repository | string | `"autoscaling/cluster-autoscaler"` | Image repository |
| autoscaler.image.tag | string | `"v1.23.0"` | Image tag |
| autoscaler.imagePullSecrets | list | `[]` | Image pull Secrets |
| autoscaler.injectProxy | bool | `false` | Inject Proxy as Environment Variables |
| autoscaler.labels | object | `{}` | Labels for Workload |
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

---
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| autoscaler.autoscaling.maxReplicas | int | `100` | Maximum available Replicas |
| autoscaler.autoscaling.minReplicas | int | `1` | Minimum available Replicas |
| autoscaler.autoscaling.targetCPUUtilizationPercentage | int | `80` | Benchmark CPU Usage |
| autoscaler.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Benchmark Memory Usage |

#### Metrics

---
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