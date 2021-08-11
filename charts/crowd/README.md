# Crowd

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Manage users from multiple directories - Active Directory, LDAP, OpenLDAP or Microsoft Azure AD - and control application authentication permissions in one single location

**Homepage:** <https://www.atlassian.com/software/crowd>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SRE | sre@bedag.ch |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../manifests | manifests | ~0.6.0 |

## Source Code

* <https://hub.docker.com/r/atlassian/crowd>

# Major Changes

Major Changes to functions are documented with the version affected. **Before upgrading the dependency version, check this section out!**

| **Change** | **Chart Version** | **Description** | **Commits/PRs** |
| :----------- | :---------------- | :--------------------- | :-------------- |
|||||

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.annotations | object | `{}` | Configure HPA Annotations |
| autoscaling.apiVersion | string | `""` | Configure the api version used for the Job resource. |
| autoscaling.behavior | object | `{}` | Define [Scaling Policies](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-configurable-scaling-behavior) for the HPA resource. |
| autoscaling.enabled | bool | `true` |  Enable HPA resource |
| autoscaling.labels | object | `{}` | Merges given labels with common labels |
| autoscaling.maxReplicas | string | `nil` | maxReplicas is the upper limit for the number of replicas to which the autoscaler can scale up. It cannot be less that minReplicas. |
| autoscaling.metrics | list | `[]` | Define [Custom Metrics](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics) rules |
| autoscaling.minReplicas | string | 1 | minReplicas is the lower limit for the number of replicas to which the autoscaler can scale down. It defaults to 1 pod. |
| autoscaling.scaleTargetRef | string | `nil` | scaleTargetRef points to the target resource to scale, and is used to the pods for which metrics should be collected, as well as to actually change the replica count. |
| autoscaling.targetCPUUtilizationPercentage | string | `nil` | Set the averageUtilization for the CPU resrouce as integer percentage (e.g. 50 = 50%) |
| autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Set the averageUtilization for the Memory resrouce as integer percentage (e.g. 50 = 50%) |
| cache.accessModes | list | `["ReadWriteOnce"]` | Define Access modes for Crowd Cache persistence |
| cache.annotations | object | `{}` | Define storageclass for Crowd Cache Persistent Volume Claim |
| cache.enabled | bool | `false` | Enable persistent Crowd Home Cache |
| cache.size | string | `"2Gi"` | Define requested storage size for Crowd Cache |
| cache.storageClass | string | `""` | Define storageclass for Crowd Cache Persistence |
| commonLabels | object | `{}` | Common Labels are added to each kubernetes resource manifest. |
| crowd.catalina_opts | list | `[]` | Enter Catalina Options which are used for the `CATALINA_OPTS` environment variables |
| crowd.cluster.enabled | bool | `false` | Run Atlassian Crowd in Data Center Mode |
| crowd.cluster.nodeName | bool | `true` | If enabled automatically adds Pod Name as Node name for the cluster (`-Dcluster.node.name=crowd-X`) |
| crowd.home | string | `"/var/atlassian/application-data/crowd"` | Atlassian Crowd Home Directory |
| crowd.jvm_args | list | `[]` | Enter JVM Options which are used for the `JVM_SUPPORT_RECOMMENDED_ARGS` environment variables |
| crowd.memory.max | string | `"768m"` | Maxium JVM Memory (`JVM_MAXIMUM_MEMORY`) |
| crowd.memory.min | string | `"384m"` | Minimum JVM Memory (`JVM_MINIMUM_MEMORY`) |
| crowd.persistence | bool | `true` | Disable predefined persistence for crowd |
| crowd.port | int | `8095` | Port published on Crowd Pod |
| crowd.timezone | string | "UTC" | Define the timezone for the crowd instance |
| extraResources | list | `[]` | Enter Extra Resources managed by the Crowd Release |
| fullnameOverride | string | `""` | Overwrite `lib.utils.common.fullname` output |
| global.defaultTag | string | `""` | Global Docker Image Tag declaration. Will be used as default tag, if no tag is given by child |
| global.imagePullPolicy | string | `""` | Global Docker Image Pull Policy declaration. Will overwrite all child .pullPolicy fields. |
| global.imagePullSecrets | list | `[]` | Global Docker Image Pull Secrets declaration. Added to local Docker Image Pull Secrets. |
| global.imageRegistry | string | `""` | Global Docker Image Registry declaration. Will overwrite all child .registry fields. |
| global.storageClass | string | `""` | Global StorageClass declaration. Can be used to overwrite StorageClass fields. |
| home.accessModes | list | `["ReadWriteOnce"]` | Define Access modes for Crowd Home |
| home.annotations | object | `{}` | Define storageclass for Crowd Home Persistent Volume Claim |
| home.enabled | bool | `true` | Enable persistent Crowd Home |
| home.size | string | `"10Gi"` | Define requested storage size for Crowd Home |
| home.storageClass | string | `""` | Define storageclass for Crowd Home Persistence |
| ingress.annotations | object | `{}` | Configure Ingress Annotations |
| ingress.apiVersion | string | `""` | Configure the api version used for the ingress resource. |
| ingress.backend | object | `{}` | Configure a [default backend](https://kubernetes.io/docs/concepts/services-networking/ingress/#default-backend) for this ingress resource |
| ingress.customRules | list | `[]` | Configure Custom Ingress [Rules](https://kubernetes.io/docs/concepts/services-networking/ingress/#resource-backend) |
| ingress.enabled | bool | `false` | Enable Ingress Resource |
| ingress.hosts | list | `[]` | Configure Ingress [Hosts](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-rules) (Required) |
| ingress.ingressClass | string | `""` | Configure the [default ingress class](https://kubernetes.io/docs/concepts/services-networking/ingress/#default-ingress-class) for this ingress. |
| ingress.labels | object | `{}` | Configure Ingress additional Labels |
| ingress.tls | list | `[]` | Configure Ingress [TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) |
| jmxExporter.config | object | See values.yaml | Configure JMX Exporter configuration. The `jmxUrl` configuration will be set automatically, if not overwritten. [See all Configurations](https://github.com/prometheus/jmx_exporter#configuration) |
| jmxExporter.enabled | bool | `false` | Enables [JMX Exporter](https://github.com/bitnami/bitnami-docker-jmx-exporter) as Sidecar |
| jmxExporter.endpoint | object | `{"interval":"10s","path":"/","scrapeTimeout":"10s"}` | Additional Configuration for the ServiceMonitor Endpoint (Overwrites .serviceMonitor.endpoints) |
| jmxExporter.labels | object | `{"app.kubernetes.io/component":"metrics"}` | Component Specific Labels. |
| jmxExporter.name | string | `"jmx"` | Name for all component parts (ports, resources). Useful when you are using the component multiple times |
| jmxExporter.port | int | `5556` | Exposed JMX Exporter Port (Service and Sidecar) |
| jmxExporter.targetPort | int | `5555` | Define which Port to scrape. Points to the Port where the jmx metrics are exposed on the Maincar. |
| kubeCapabilities | string | `$.Capabilities.KubeVersion.GitVersion` | Overwrite the Kube GitVersion |
| nameOverride | string | `""` | Overwrite "lib.internal.common.name" output |
| overwriteLabels | object | `{}` | Overwrites default labels, but not resource specific labels and common labels |
| pdb.apiVersion | string | `""` | Configure the api version used for the Pdb resource |
| pdb.enabled | bool | `true` | Enable Pdb Resource |
| pdb.labels | object | `{}` | Merges given labels with common labels |
| pdb.maxUnavailable | string | `nil` | Number or percentage of pods which is allowed to be unavailable during a disruption |
| pdb.minAvailable | string | `nil` | Number or percentage of pods which must be available during a disruption. If neither `minAvailable` or `maxUnavailable` is set, de Policy defaults to `minAvailable: 1` |
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
| service.port | int | 80 | Configure Service Port (Required) |
| service.portName | string | http | Configure Service Port name |
| service.selector | object | `{}` | Configure Service Selector Labels |
| service.targetPort | string | http | Configure Service TargetPort |
| service.type | string | `"ClusterIP"` | Configure Service [Type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types). |
| shared.accessModes | list | `["ReadWriteMany"]` | Configure PVC [Access Modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) |
| shared.annotations | object | `{}` | Configure PVC additional Annotations ([Monitor Labels](https://www.weave.works/docs/cloud/latest/tasks/monitor/configuration-k8s/)) |
| shared.apiVersion | string | `""` | Configure the api version used for the Pod resource |
| shared.dataSource | string | `nil` | Data Sources are currently only supported for [CSI Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-snapshot-and-restore-volume-from-snapshot-support) |
| shared.enabled | bool | `true` | Enable PVC Resource |
| shared.labels | object | `bedag-lib.commonLabels` | Merges given labels with common labels |
| shared.selector | object | `{}` | Configure PVC [Selector](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector) |
| shared.size | string | `"10Gi"` | Define requested storage size |
| shared.storageClass | string | `""` | Configure PVC [Storage Class](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#class-1) |
| statefulset.affinity | object | `{}` | Pod [Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
| statefulset.apiVersion | string | `""` | Configure the api version used for the Statefulset resource |
| statefulset.args | object | `{}` | Configure arguments for executed command |
| statefulset.command | object | `{}` | Configure executed container command |
| statefulset.containerFields | object | `{}` | Extra fields used on the container definition |
| statefulset.containerName | string | `.Chart.Name` | Configure Container Name |
| statefulset.environment | list | `[]` | Configure Environment Variables (Refer to values.yaml) |
| statefulset.forceRedeploy | bool | `false` |  |
| statefulset.image.pullPolicy | string | `nil` | Configure Docker Pull Policy. Will be overwritten if set by global variable. |
| statefulset.image.registry | string | `"docker.io"` | Configure Docker Registry. Will be overwritten if set by global variable. |
| statefulset.image.repository | string | `"atlassian/crowd"` | Configure Docker Repository |
| statefulset.image.tag | string | Tag defaults to `.Chart.Appversion`, if not set | Configure Docker Image tag |
| statefulset.imagePullSecrets | list | `[]` | Define [ImagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). Will be overwritten if set by global variable. |
| statefulset.initContainers | list | `[]` | Pod [initContainers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) |
| statefulset.labels | object | `{}` | Merges given labels with common labels |
| statefulset.lifecycle | object | `{}` | Container [Lifecycle](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/) |
| statefulset.livenessProbe | object | `{"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}` | Container [LivenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command) |
| statefulset.nodeSelector | object | `{}` | Pod [NodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| statefulset.podAnnotations | object | `{}` | Pod [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) are only added for the pod |
| statefulset.podFields | object | `{}` | Add extra field to the [Pod Template](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podtemplate-v1-core) if not available as value. |
| statefulset.podLabels | object | `{}` | Pod [labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) are only added for the pod |
| statefulset.podManagementPolicy | string | `""` | Statefulset [Management Policy](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies). **Statefulset only** |
| statefulset.podSecurityContext | object | `{}` | Pod [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| statefulset.ports | list | `[]` | Configure Container Ports |
| statefulset.priorityClassName | string | `""` | Pod [priorityClassName](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass) |
| statefulset.readinessProbe | object | `{"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}` | Container [ReadinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes) |
| statefulset.replicaCount | int | `1` | Amount of Replicas deployed |
| statefulset.resources | object | `{}` | Configure Container [Resource](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| statefulset.restartPolicy | string | `nil` | Restart policy for all containers within the pod. One of Always, OnFailure, Never. Default to Always. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy |
| statefulset.rollingUpdatePartition | string | `""` | Statefulset [Update Pratition](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#partitions). **Statefulset only** |
| statefulset.securityContext | object | `{}` | Container [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| statefulset.selectorLabels | object | `{}` | Define SelectorLabels for the Pod Template |
| statefulset.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| statefulset.serviceAccount.apiVersion | string | v1 | Configure the api version used |
| statefulset.serviceAccount.automountServiceAccountToken | bool | `true` | (bool) AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted. |
| statefulset.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| statefulset.serviceAccount.enabled | bool | `false` | Specifies whether a service account is enabled or not |
| statefulset.serviceAccount.globalPullSecrets | bool | `false` | Evaluate global set pullsecrets and mount, if set |
| statefulset.serviceAccount.imagePullSecrets | list | `[]` | ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount. |
| statefulset.serviceAccount.labels | object | `{}` | Merges given labels with common labels |
| statefulset.serviceAccount.name | string | `""` | If not set and create is true, a name is generated using the fullname template |
| statefulset.serviceAccount.secrets | list | `[]` | Secrets is the list of secrets allowed to be used by pods running using this ServiceAccount |
| statefulset.serviceName | string | `""` | Define a Service for the Statefulset |
| statefulset.sidecars | list | `[]` | Allows to add sidecars to your [maincar]](https://kubernetes.io/docs/concepts/workloads/pods/#using-pods) |
| statefulset.startupProbe | object | `{}` | Container [StartupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes) |
| statefulset.statefulsetExtras | object | `{}` | Extra Fields for Statefulset Manifest |
| statefulset.tolerations | object | `{}` | Pod [Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| statefulset.updateStrategy | string | `"RollingUpdate"` | Statefulset [Update Strategy](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets). **Statefulset only** |
| statefulset.volumeClaimTemplates | list | `[]` | Statefulset [volumeClaimTemplates](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#components). **Statefulset only** |
| statefulset.volumeMounts | list | `[]` | Configure Container [volumeMounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/) |
| statefulset.volumes | list | `[]` | Additional [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) |
| volumePermissions.directories | list | `["/crowd"]` | Configure destination directories. The Change Owner/Mode operation will be applied to these directories. Can be String or Slice. |
| volumePermissions.enabled | bool | `false` | Enables Volume Permissions |
| volumePermissions.mode | int | `nil` | Configure permission mode (eg. 755). If not set no permission mode will be applied. |
| volumePermissions.name | string | `permission` | Volume Permission Container Name |
| volumePermissions.runAsGroup | int | `2004` | (int) Configure the directory Group Owner. |
| volumePermissions.runAsUser | int | `2004` | (int) Configure the directory User Owner. |

This Chart implements the Bedag Manifest Chart. Therefor there are a lot of values for you to play around.

## Configuration

Generally Configuration for Crowd is done via Environment variables. See all the possible configurations on the [Crowd Docker Image](https://hub.docker.com/r/atlassian/crowd). Our intent with this chart is to keep configurations and resource layout as flexible as possible. This way have the possibility the deploy Crowd to your needs.

### Server Mode (Standalone)

When running Crowd in Server Mode, you can have a single instance of Crowd running simultaneously.

To Run Crowd in Server Mode, simply toggle the `crowd.cluster.enabled` option to `false`:

```
crowd:
  cluster:
    enabled: false
```

### Data Center Mode (Clustered)

When running Crowd in Data Center Mode, you have the ability to have multiple Crowd instances running at once, providing a HA setup. For more information read about [Crowd Data Center](https://www.atlassian.com/enterprise/data-center/crowd)

To run Crowd in Data Center Mode, simply toggle the `crowd.cluster.enabled` option to `true`:

```
crowd:
  cluster:
    enabled: true
```

By enabling clustered mode, you enable the following resources, which aren't available in standalone mode:

  * [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
  * [Shared PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

These are only useful when running Data Center Mode.

### Persistence (Server/Data Center)

Read the following before configuring persistence for your Crowd instance.

Currently there are three default mounts supported by this chart:

  * `$.Values.home` - Mounts a volume to the entire Crowd home directory (`$.Values.crowd.home`)
  * `$.Values.shared` - Mounts a volume to the `shared` directory in the Crowd home (Data Center only)

If that doesn't fit your setup, you can add your volumes/volumemounts through given values and disable the named volumes.

#### Disable Persistence

Disable all the predefined persistence from the chart (Will disable all the above mentioned mounts):

```
crowd:
  persistence: false
```

Disable persistence for the Home directory

```
home:
  enabled: false
```

Disable persistence for the Shared directory (Data Center Only)

```
shared:
  enabled: false
```

### Tomcat Proxy

If your Crowd instance is deployed behind a reverse proxy/ingress, then you will need to specify the following environment variables

```
- name: ATL_PROXY_NAME
  value: "{ (index .Values.ingress.hosts 0).host }"
- name: ATL_PROXY_PORT
  value: "443"
- name: ATL_TOMCAT_SCHEME
  value: "https"
- name: ATL_TOMCAT_SECURE
  value: "true"
```

More information about the image can be found on the [Crowd documentation](https://hub.docker.com/r/atlassian/crowd).

### VolumePermissions

VolumePermissions is a slim initContainer, which sets the correct permissions on all the mounts. This is effectively required only the first time the application is deployed. We recommend disabling it when having large data directories in your jira home, since the startup could extend to several minutes. Disable volumePermissions like:

```
volumePermissions:
  enabled: false
```

## Known Issues/Solutions

Here we have documented some issues and solutions while running Crowd on Kubernetes.

### Data Center Setup

Here's how we got Crowd in Data Center working.

  1. Spin up the first deployment with a single Pod.
  2. Go through the setup via Web interface (Setup license etc.)
    * When altering the Database configuration crowd will reload itself. **Don't** touch anything while it's doing that. Watch the logs and reaccess is via Web Interface only after it says it's ready. We had very weird behaviors when not doing so.
  3. When the instance is functional, scale up the amount of pods and confirm they are joining the cluster.

If you encounter any other issues or have tips, let us know.

### Database Changelog Lock

This can happen when the livenessprobe kills crowd to early. You will find the following message in your pod (and it will be crashing):

```
[liquibase] Waiting for changelog lock....
```

You will need to do some fixing in the database. [See the following article for more](https://confluence.atlassian.com/crowdkb/crowd-server-does-not-start-could-not-acquire-change-log-lock-1019399699.html). To prevent this, increase the `initialDelaySeconds` value for the livenessProbe.

