# kafdrop

![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.27.0](https://img.shields.io/badge/AppVersion-3.27.0-informational?style=flat-square)

Unofficial Helm Chart for Kafdrop

**Homepage:** <https://github.com/obsidiandynamics/kafdrop>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SRE | sre@bedag.ch |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://bedag.github.io/helm-charts/ | manifests | ~0.4.11 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.annotations | object | `{}` | Configure HPA Annotations |
| autoscaling.apiVersion | string | `""` | Configure the api version used for the Job resource. |
| autoscaling.behavior | object | `{}` | Define [Scaling Policies](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-configurable-scaling-behavior) for the HPA resource. |
| autoscaling.enabled | bool | `true` | Enable HPA resource |
| autoscaling.labels | object | `{}` | Merges given labels with common labels |
| autoscaling.maxReplicas | string | `nil` | maxReplicas is the upper limit for the number of replicas to which the autoscaler can scale up. It cannot be less that minReplicas. |
| autoscaling.metrics | list | `[]` | Define [Custom Metrics](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics) rules |
| autoscaling.minReplicas | string | 1 | minReplicas is the lower limit for the number of replicas to which the autoscaler can scale down. It defaults to 1 pod. |
| autoscaling.targetCPUUtilizationPercentage | string | `nil` | Set the averageUtilization for the CPU resrouce as integer percentage (e.g. 50 = 50%) |
| autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Set the averageUtilization for the Memory resrouce as integer percentage (e.g. 50 = 50%) |
| commonLabels | object | `{}` | Common Labels are added to each kubernetes resource manifest. |
| config.jvm[0] | string | `"-Xms128M"` |  |
| config.jvm[1] | string | `"-Xmx256M"` |  |
| config.kafka.connections[0] | string | `"localhost:9092"` |  |
| config.kafka.keystore.content | string | `""` |  |
| config.kafka.keystore.destination | string | `"kafka.keystore.jks"` |  |
| config.kafka.properties.content | string | `"{{ toString \"sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username='suchUser' password='veryS3CRET';\\nsecurity.protocol=SASL_PLAINTEXT\\nsasl.mechanism=PLAIN\" | b64enc }}\n"` |  |
| config.kafka.properties.destination | string | `"kafka.properties"` |  |
| config.kafka.truststore.content | string | `""` |  |
| config.kafka.truststore.destination | string | `"kafka.truststore.jks"` |  |
| config.protoDesc.enabled | bool | `false` |  |
| config.protoDesc.files | list | `[]` |  |
| config.protoDesc.path | string | `"/proto-descriptors"` |  |
| config.server.context | string | `"/"` |  |
| config.server.port | string | `"9000"` |  |
| deployment.affinity | object | `{}` | Pod [Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
| deployment.apiVersion | string | `""` | Configure the api version used for the Deployment resource |
| deployment.args | object | `{}` | Configure arguments for executed command |
| deployment.command | object | `{}` | Configure executed container command |
| deployment.containerFields | object | `{}` | Extra fields used on the container definition |
| deployment.containerName | string | `.Chart.Name` | Configure Container Name |
| deployment.deploymentExtras | object | `{}` |  |
| deployment.environment | object | `{}` | Configure Environment Variables (Refer to values.yaml) |
| deployment.forceRedeploy | bool | `false` |  |
| deployment.image.pullPolicy | string | `nil` | Configure Docker Pull Policy. Will be overwritten if set by global variable. |
| deployment.image.registry | string | `"docker.io"` | Configure Docker Registry. Will be overwritten if set by global variable. |
| deployment.image.repository | string | `"obsidiandynamics/kafdrop"` | Configure Docker Repository |
| deployment.image.tag | string | Tag defaults to `.Chart.Appversion`, if not set | Configure Docker Image tag |
| deployment.imagePullSecrets | list | `[]` | Define [ImagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). Will be overwritten if set by global variable. |
| deployment.initContainers | list | `[]` | Pod [initContainers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) |
| deployment.labels | object | `{}` | Merges given labels with common labels |
| deployment.lifecycle | object | `{}` | Container [Lifecycle](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/) |
| deployment.livenessProbe | object | `{"httpGet":{"path":"{{ include \"kafdrop.endpoint\" $ }}","port":"http"},"initialDelaySeconds":60}` | Container [LivenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command) |
| deployment.nodeSelector | object | `{}` | Pod [NodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| deployment.podAnnotations | object | `{}` | Pod [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) are only added for the pod |
| deployment.podFields | object | `{}` | Add extra field to the [Pod Template](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podtemplate-v1-core) if not available as value. |
| deployment.podLabels | object | `{}` | Pod [labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) are only added for the pod |
| deployment.podSecurityContext | object | `{}` | Pod [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| deployment.ports | object | `{}` | Configure Container Ports |
| deployment.priorityClassName | string | `""` | Pod [priorityClassName](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass) |
| deployment.readinessProbe | object | `{"httpGet":{"path":"{{ include \"kafdrop.endpoint\" $ }}","port":"http"},"initialDelaySeconds":60}` | Container [ReadinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes) |
| deployment.replicaCount | int | 1 | Amount of Replicas deployed |
| deployment.resources | object | `{}` | Configure Container [Resource](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| deployment.restartPolicy | string | `nil` | Restart policy for all containers within the pod. One of Always, OnFailure, Never. Default to Always. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy |
| deployment.securityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Container [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| deployment.selectorLabels | object | `{}` | Define SelectorLabels for the Pod Template |
| deployment.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| deployment.serviceAccount.apiVersion | string | v1 | Configure the api version used |
| deployment.serviceAccount.automountServiceAccountToken | bool | `true` | (bool) AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted. |
| deployment.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| deployment.serviceAccount.enabled | bool | `false` | Specifies whether a service account is enabled or not |
| deployment.serviceAccount.globalPullSecrets | bool | `false` | Evaluate global set pullsecrets and mount, if set |
| deployment.serviceAccount.imagePullSecrets | list | `[]` | ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount. |
| deployment.serviceAccount.labels | object | `{}` | Merges given labels with common labels |
| deployment.serviceAccount.name | string | `""` | If not set and create is true, a name is generated using the fullname template |
| deployment.serviceAccount.secrets | list | `[]` | Secrets is the list of secrets allowed to be used by pods running using this ServiceAccount |
| deployment.sidecars | list | `[]` | Allows to add sidecars to your [maincar]](https://kubernetes.io/docs/concepts/workloads/pods/#using-pods) |
| deployment.startupProbe | object | `{}` | Container [StartupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes) |
| deployment.strategy | object | `{}` | Deployment [Update Strategy](https://kubernetes.io/docs/concepts/services-networking/ingress/#resource-backend). **Deployments only** |
| deployment.tolerations | object | `{}` | Pod [Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| deployment.volumeMounts | object | `{}` | Configure Container [volumeMounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/) |
| deployment.volumes | list | `[]` | Additional [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) |
| extraResources | list | `[]` | Enter Extra Resources managed by the Jira Release |
| fullnameOverride | string | `""` | Overwrite `lib.utils.common.fullname` output |
| global.defaultTag | string | `""` | Global Docker Image Tag declaration. Will be used as default tag, if no tag is given by child |
| global.imagePullPolicy | string | `""` | Global Docker Image Pull Policy declaration. Will overwrite all child .pullPolicy fields. |
| global.imagePullSecrets | list | `[]` | Global Docker Image Pull Secrets declaration. Added to local Docker Image Pull Secrets. |
| global.imageRegistry | string | `""` | Global Docker Image Registry declaration. Will overwrite all child .registry fields. |
| global.storageClass | string | `""` | Global StorageClass declaration. Can be used to overwrite StorageClass fields. |
| ingress.annotations | object | `{}` | Configure Ingress Annotations |
| ingress.apiVersion | string | `""` | Configure the api version used for the ingress resource. |
| ingress.backend | object | `{}` | Configure a [default backend](https://kubernetes.io/docs/concepts/services-networking/ingress/#default-backend) for this ingress resource |
| ingress.customRules | list | `[]` | Configure Custom Ingress [Rules](https://kubernetes.io/docs/concepts/services-networking/ingress/#resource-backend) |
| ingress.enabled | bool | `true` | Enable Ingress Resource |
| ingress.hosts | list | `[]` | Configure Ingress [Hosts](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-rules) (Required) |
| ingress.ingressClass | string | `""` | Configure the [default ingress class](https://kubernetes.io/docs/concepts/services-networking/ingress/#default-ingress-class) for this ingress. |
| ingress.labels | object | `{}` | Configure Ingress additional Labels |
| ingress.tls | list | `[]` | Configure Ingress [TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) |
| jmxExporter.args | object | `{}` | Configure arguments for executed command |
| jmxExporter.command | object | `{}` | Configure executed container command |
| jmxExporter.config | object | See values.yaml | Configure JMX Exporter configuration. The `jmxUrl` configuration will be set automatically, if not overwritten. [See all Configurations](https://github.com/prometheus/jmx_exporter#configuration) |
| jmxExporter.containerFields | object | `{}` | Extra fields used on the container definition |
| jmxExporter.containerName | string | `.Chart.Name` | Configure Container Name |
| jmxExporter.enabled | bool | `false` | Enables [JMX Exporter](https://github.com/bitnami/bitnami-docker-jmx-exporter) as Sidecar |
| jmxExporter.endpoint | object | `{"interval":"10s","path":"/","scrapeTimeout":"10s"}` | Additional Configuration for the ServiceMonitor Endpoint (Overwrites .serviceMonitor.endpoints) |
| jmxExporter.environment | object | `{}` | Configure Environment Variables (Refer to values.yaml) |
| jmxExporter.image.pullPolicy | string | `nil` | Configure Docker Pull Policy. Will be overwritten if set by global variable. |
| jmxExporter.image.registry | string | `"docker.io"` | Configure Docker Registry. Will be overwritten if set by global variable. |
| jmxExporter.image.repository | string | `"bitnami/jmx-exporter"` | Configure Docker Repository |
| jmxExporter.image.tag | string | Tag defaults to `.Chart.Appversion`, if not set | Configure Docker Image tag |
| jmxExporter.labels | object | `{"app.kubernetes.io/component":"metrics"}` | Component Specific Labels. |
| jmxExporter.lifecycle | object | `{}` | Container [Lifecycle](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/) |
| jmxExporter.livenessProbe | object | `{}` | Container [LivenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command) |
| jmxExporter.name | string | `"jmx"` | Name for all component parts (ports, resources). Useful when you are using the component multiple times |
| jmxExporter.port | int | `5556` | Exposed JMX Exporter Port (Service and Sidecar) |
| jmxExporter.ports | object | `{}` | Configure Container Ports |
| jmxExporter.readinessProbe | object | `{}` | Container [ReadinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes) |
| jmxExporter.resources | object | `{}` | Configure Container [Resource](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| jmxExporter.securityContext | object | `{}` | Container [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| jmxExporter.service.annotations | object | `{}` | Configure Service additional Annotations ([Monitor Labels](https://www.weave.works/docs/cloud/latest/tasks/monitor/configuration-k8s/)) |
| jmxExporter.service.apiVersion | string | v1 | Configure the api version used |
| jmxExporter.service.enabled | bool | `true` | Enable Service Resource |
| jmxExporter.service.extraPorts | list | `[]` | Add additional ports to the service |
| jmxExporter.service.labels | object | `{}` | Configure Service additional Labels |
| jmxExporter.service.loadBalancerIP | string | `""` | Configure Service [loadBalancerIP](https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer). Set the LoadBalancer service type to internal only. |
| jmxExporter.service.loadBalancerSourceRanges | list | `[]` | Configure Service [loadBalancerSourceRanges](https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service) |
| jmxExporter.service.nodePort | string | `""` | Specify the nodePort value for the LoadBalancer and NodePort service types |
| jmxExporter.service.port | string | 80 | Configure Service Port (Required) |
| jmxExporter.service.portName | string | http | Configure Service Port name |
| jmxExporter.service.selector | object | `{}` | Configure Service Selector Labels |
| jmxExporter.service.targetPort | string | http | Configure Service TargetPort |
| jmxExporter.service.type | string | `"ClusterIP"` | Configure Service [Type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types). |
| jmxExporter.serviceMonitor.additonalFields | object | `{}` | Define additional fields, which aren't available as seperat key (e.g. `sampleLimit`) |
| jmxExporter.serviceMonitor.apiVersion | string | `""` | Configure the api version used for the ServiceMonitor resource |
| jmxExporter.serviceMonitor.enabled | bool | `true` | Enable serviceMonitor Resource |
| jmxExporter.serviceMonitor.endpoints | object | `{}` | Configure Prometheus ServiceMonitor [Endpoints](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#endpoint) |
| jmxExporter.serviceMonitor.labels | object | `{}` | Configure Prometheus ServiceMonitor labels |
| jmxExporter.serviceMonitor.namespace | string | `""` |  |
| jmxExporter.serviceMonitor.namespaceSelector | list | `$.Release.Namespace` | Define which Namespaces to watch. Can either be type string or slice |
| jmxExporter.serviceMonitor.selector | object | `{}` | Configure Prometheus ServiceMonitor Selector |
| jmxExporter.startupProbe | object | `{}` | Container [StartupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes) |
| jmxExporter.targetPort | int | `5555` | Define which Port to scrape. Points to the Port where the jmx metrics are exposed on the Maincar. |
| jmxExporter.volumeMounts | object | `{}` | Configure Container [volumeMounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/) |
| kubeCapabilities | string | `$.Capabilities.KubeVersion.GitVersion` | Overwrite the Kube GitVersion |
| nameOverride | string | `""` | Overwrite "lib.internal.common.name" output |
| overwriteLabels | object | `{}` | Overwrites default labels, but not resource specific labels and common labels |
| pdb.apiVersion | string | `""` | Configure the api version used for the Pdb resource |
| pdb.enabled | bool | `true` | Enable Pdb Resource |
| pdb.labels | object | `{}` | Merges given labels with common labels |
| pdb.maxUnavailable | string | `nil` | Number or percentage of pods which is allowed to be unavailable during a disruption |
| pdb.minAvailable | string | `nil` | Number or percentage of pods which must be available during a disruption. If neither `minAvailable` or `maxUnavailable` is set, the Policy defaults to `minAvailable: 1` |
| pdb.selectorLabels | object | `{}` | Define SelectorLabels for the pdb |
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
| service.extraPorts | list | `[]` | Add additional ports to the service |
| service.labels | object | `{}` | Configure Service additional Labels |
| service.loadBalancerIP | string | `""` | Configure Service [loadBalancerIP](https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer). Set the LoadBalancer service type to internal only. |
| service.loadBalancerSourceRanges | list | `[]` | Configure Service [loadBalancerSourceRanges](https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service) |
| service.nodePort | string | `""` | Specify the nodePort value for the LoadBalancer and NodePort service types |
| service.port | int | `9000` | Configure Service Port (Required) |
| service.portName | string | http | Configure Service Port name |
| service.selector | object | `{}` | Configure Service Selector Labels |
| service.targetPort | string | http | Configure Service TargetPort |
| service.type | string | `"ClusterIP"` | Configure Service [Type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types). |
| timezone | string | `"Europe/Zurich"` | Define Container Timezone (Sets TZ Environment) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
