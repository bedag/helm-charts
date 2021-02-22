# E2guardian

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

e2guardian Chart

The chart is under active development and may contain bugs/unfinished documentation. Any testing/contributions are welcome! :)

**Homepage:** <https://github.com/e2guardian/e2guardian/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| NOC | noc@bedag.ch |  |
| SRE | sre@bedag.ch |  |

## Source Code

* <https://github.com/bedag/helm-charts/tree/master/charts/e2g>
* <https://github.com/e2guardian/e2guardian/>
* <https://github.com/bedag/docker-e2g>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://bedag.github.io/helm-charts/ | manifests | >=0.4.0 |

# How to use this Chart?

You can choose between `deployment`, `statefulset`, `daemonset`. Deployment is per default enabled. You can enable disable those like this:
```
deployment:
  enabled: true
statefulset:
  enabled: false
daemonset:
  enabled: false
```

All important E2guardian variables are under `e2g`. Go to [Values](#Values) for more information.

See the [Examples](./examples) to get a better idea, of how tests could look like.

# Major Changes

Major Changes to functions are documented with the version affected. **Before upgrading the dependency version, check this section out!**

| **Change** | **Chart Version** | **Description** | **Commits/PRs** |
| :--------- | :---------------- | :-------------- | :-------------- |
|||||

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonLabels | object | `{}` | Common Labels are added to each kubernetes resource manifest. |
| daemonset.apiVersion | string | `""` | Configure the api version used for the DaemonSet resource |
| daemonset.enabled | bool | `false` | Enable daemonset |
| daemonset.labels | object | `{}` | Merges given labels with common labels |
| daemonset.minReadySeconds | string | `""` | DaemonSet [Min Ready in Seconds](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/#performing-a-rolling-update). **DaemonSet only** |
| daemonset.rollingUpdatemaxUnavailable | string | `""` |  |
| daemonset.selectorLabels | object | `{}` | Define SelectorLabels for the Pod Template |
| daemonset.updateStrategy | string | `"RollingUpdate"` | DaemonSet [Update Strategy](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/#performing-a-rolling-update). **DaemonSet only** |
| deployment.apiVersion | string | `""` | Configure the api version used for the Deployment resource |
| deployment.deploymentExtras | object | `{}` | Extra Fields for Deployment Manifest |
| deployment.enabled | bool | `true` | Enable deployment |
| deployment.labels | object | `{}` | Merges given labels with common labels |
| deployment.replicaCount | int | 1 | Amount of Replicas deployed |
| deployment.selectorLabels | object | `{}` | Define SelectorLabels for the Pod Template |
| deployment.strategy | object | `{}` | Deployment [Update Strategy](https://kubernetes.io/docs/concepts/services-networking/ingress/#resource-backend). **Deployments only** |
| e2g.config | string | `nil` | e2g config as string |
| e2g.lists | list | `[]` | Array of e2g stories as string |
| e2g.story | list | `[]` | Array of e2g stories as string |
| fullnameOverride | string | `""` | Overwrite `lib.utils.common.fullname` output |
| global.defaultTag | string | `""` | Global Docker Image Tag declaration. Will be used as default tag, if no tag is given by child |
| global.imagePullPolicy | string | `""` | Global Docker Image Pull Policy declaration. Will overwrite all child .pullPolicy fields. |
| global.imagePullSecrets | list | `[]` | Global Docker Image Pull Secrets declaration. Added to local Docker Image Pull Secrets. |
| global.imageRegistry | string | `""` | Global Docker Image Registry declaration. Will overwrite all child .registry fields. |
| global.storageClass | string | `""` | Global StorageClass declaration. Can be used to overwrite StorageClass fields. |
| kubeCapabilities | string | `$.Capabilities.KubeVersion.GitVersion` | Overwrite the Kube GitVersion |
| nameOverride | string | `""` | Overwrite "lib.internal.common.name" output |
| overwriteLabels | object | `{}` | Overwrites default labels, but not resource specific labels and common labels |
| pod.affinity | object | `{}` | Pod [Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
| pod.apiVersion | string | `""` | Configure the api version used for the Pod resource |
| pod.args | object | `{}` | Configure arguments for executed command |
| pod.command | object | `{}` | Configure executed container command |
| pod.containerFields | object | `{}` | Extra fields used on the container definition |
| pod.containerName | string | `.Chart.Name` | Configure Container Name |
| pod.environment | list | `[]` | Configure Environment Variables (Refer to values.yaml) |
| pod.forceRedeploy | bool | `false` |  |
| pod.image.pullPolicy | string | `nil` | Configure Docker Pull Policy. Will be overwritten if set by global variable. |
| pod.image.registry | string | `"docker.io"` | Configure Docker Registry. Will be overwritten if set by global variable. |
| pod.image.repository | string | `"bedag/e2g"` | Configure Docker Repository |
| pod.image.tag | string | Tag defaults to `.Chart.Appversion`, if not set | Configure Docker Image tag |
| pod.imagePullSecrets | list | `[]` | Define [ImagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). Will be overwritten if set by global variable. |
| pod.initContainers | list | `[]` | Pod [initContainers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) |
| pod.lifecycle | object | `{}` | Container [Lifecycle](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/) |
| pod.livenessProbe | object | `{"initialDelaySeconds":15,"periodSeconds":1,"tcpSocket":{"port":1344}}` | Container [LivenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command) |
| pod.nodeSelector | object | `{}` | Pod [NodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| pod.podAnnotations | object | `{}` | Pod [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) are only added for the pod |
| pod.podFields | object | `{"terminationGracePeriodSeconds":0}` | Add extra field to the [Pod Template](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podtemplate-v1-core) if not available as value. |
| pod.podLabels | object | `{}` | Pod [labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) are only added for the pod |
| pod.podSecurityContext | object | `{"runAsNonRoot":true,"runAsUser":65534}` | Pod [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| pod.ports | list | `[{"containerPort":1344,"name":"icap","protocol":"TCP"},{"containerPort":8080,"name":"http","protocol":"TCP"},{"containerPort":8443,"name":"https","protocol":"TCP"}]` | Configure Container Ports |
| pod.priorityClassName | string | `""` | Pod [priorityClassName](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass) |
| pod.readinessProbe | object | `{"initialDelaySeconds":5,"periodSeconds":1,"tcpSocket":{"port":1344}}` | Container [ReadinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes) |
| pod.resources | object | `{}` | Configure Container [Resource](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| pod.restartPolicy | string | `nil` | Restart policy for all containers within the pod. One of Always, OnFailure, Never. Default to Always. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy |
| pod.securityContext | object | `{}` | Container [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| pod.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| pod.serviceAccount.apiVersion | string | v1 | Configure the api version used |
| pod.serviceAccount.automountServiceAccountToken | bool | `true` | (bool) AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted. |
| pod.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| pod.serviceAccount.enabled | bool | `false` | Specifies whether a service account is enabled or not |
| pod.serviceAccount.globalPullSecrets | bool | `false` | Evaluate global set pullsecrets and mount, if set |
| pod.serviceAccount.imagePullSecrets | list | `[]` | ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount. |
| pod.serviceAccount.labels | object | `{}` | Merges given labels with common labels |
| pod.serviceAccount.name | string | `""` | If not set and create is true, a name is generated using the fullname template |
| pod.serviceAccount.secrets | list | `[]` | Secrets is the list of secrets allowed to be used by pods running using this ServiceAccount |
| pod.sidecars | list | `[]` | Allows to add sidecars to your [maincar]](https://kubernetes.io/docs/concepts/workloads/pods/#using-pods) |
| pod.startupProbe | object | `{}` | Container [StartupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes) |
| pod.tolerations | object | `{}` | Pod [Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| pod.volumeMounts | list | `[]` | Configure Container [volumeMounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/) |
| pod.volumes | list | `[]` | Additional [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) |
| proxy.httpProxy.host | string | `""` | Configure HTTP Proxy Hostname/IP (without protocol://) |
| proxy.httpProxy.port | int | `nil` | Configure HTTP Proxy Port |
| proxy.httpProxy.protocol | string | http | Configure HTTP Proxy Protocol (http/https) |
| proxy.httpsProxy.host | string | `""` | Configure HTTPS Proxy Hostname/IP (without protocol://) |
| proxy.httpsProxy.port | int | `nil` | Configure HTTPS Proxy Port |
| proxy.httpsProxy.protocol | string | http | Configure HTTPS Proxy Protocol (http/https) |
| proxy.noProxy | list | `[]` | Configure No Proxy Hosts noProxy: [ "localhost", "127.0.0.1" ] |
| selectorLabels | object | `{}` | Define default [selectorLabels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| service.annotations | object | `{}` | Configure Service additional Annotations ([Monitor Labels](https://www.weave.works/docs/cloud/latest/tasks/monitor/configuration-k8s/)) |
| service.apiVersion | string | v1 | Configure the api version used |
| service.enabled | bool | `true` | Enable Service Resource |
| service.extraPorts | list | `[{"name":"http","port":8080,"protocol":"TCP","targetPort":"http"},{"name":"https","port":8443,"protocol":"TCP","targetPort":"https"}]` | Add additional ports to the service |
| service.labels | object | `{}` | Configure Service additional Labels |
| service.loadBalancerIP | string | `""` | Configure Service [loadBalancerIP](https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer). Set the LoadBalancer service type to internal only. |
| service.loadBalancerSourceRanges | list | `[]` | Configure Service [loadBalancerSourceRanges](https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service) |
| service.nodePort | string | `nil` | Specify the nodePort value for the LoadBalancer and NodePort service types |
| service.port | int | 80 | Configure Service Port (Required) |
| service.portName | string | http | Configure Service Port name |
| service.protocol | string | TCP | Configure Service Port Protocol |
| service.selector | object | `{}` | Configure Service Selector Labels |
| service.targetPort | string | http | Configure Service TargetPort |
| service.type | string | `""` | Configure Service [Type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types). |
| statefulset.apiVersion | string | `""` | Configure the api version used for the Statefulset resource |
| statefulset.enabled | bool | `false` | Enable statefulset |
| statefulset.labels | object | `{}` | Merges given labels with common labels |
| statefulset.podManagementPolicy | string | `""` | Statefulset [Management Policy](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies). **Statefulset only** |
| statefulset.replicaCount | int | `1` | Amount of Replicas deployed |
| statefulset.rollingUpdatePartition | string | `""` | Statefulset [Update Pratition](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#partitions). **Statefulset only** |
| statefulset.selectorLabels | object | `{}` | Define SelectorLabels for the Pod Template |
| statefulset.serviceName | string | `""` | Define a Service for the Statefulset |
| statefulset.statefulsetExtras | object | `{}` | Extra Fields for Statefulset Manifest |
| statefulset.updateStrategy | string | `"RollingUpdate"` | Statefulset [Update Strategy](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets). **Statefulset only** |
| statefulset.volumeClaimTemplates | list | `[]` | Statefulset [volumeClaimTemplates](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#components). **Statefulset only** |
| timezone | string | `"Europe/Zurich"` | Define Container Timezone (Sets TZ Environment) |
