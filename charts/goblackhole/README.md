# Goblackhole

![Version: 0.0.4](https://img.shields.io/badge/Version-0.0.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Offical Helm Chart for goblackhole

**Homepage:** <https://github.com/bedag/goblackhole>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| NOC | <noc@bedag.ch> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://bedag.github.io/helm-charts | manifests | ~0.5.0 |

## Source Code

* <https://github.com/bedag/goblackhole>
* <https://hub.docker.com/r/bedag/goblackhole>

# Major Changes

Major Changes to functions are documented with the version affected. **Before upgrading the dependency version, check this section out!**

| **Change** | **Chart Version** | **Description** | **Commits/PRs** |
| :----------- | :---------------- | :--------------------- | :-------------- |
|||||

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonLabels | string | `nil` | Common Labels are added to each kubernetes resource manifest. |
| deployment.affinity | object | `{}` | Pod [Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
| deployment.apiVersion | string | `""` | Configure the api version used for the Deployment resource |
| deployment.args | object | `{}` | Configure arguments for executed command |
| deployment.command | object | `{}` | Configure executed container command |
| deployment.containerFields | object | `{}` | Extra fields used on the container definition |
| deployment.containerName | string | `.Chart.Name` | Configure Container Name |
| deployment.deploymentExtras | object | `{}` | Extra Fields for Deployment Manifest |
| deployment.envFrom | list | `[]` | Configure Environment from Source |
| deployment.environment | list | `[]` | Configure Environment Variables (Refer to values.yaml) |
| deployment.forceRedeploy | bool | `false` |  |
| deployment.image.pullPolicy | string | `nil` | Configure Docker Pull Policy. Will be overwritten if set by global variable. |
| deployment.image.registry | string | `"docker.io"` | Configure Docker Registry. Will be overwritten if set by global variable. |
| deployment.image.repository | string | `"bedag/goblackhole"` | Configure Docker Repository |
| deployment.image.tag | string | Tag defaults to `.Chart.Appversion`, if not set | Configure Docker Image tag |
| deployment.imagePullSecrets | list | `[]` | Define [ImagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). Will be overwritten if set by global variable. |
| deployment.initContainers | list | `[]` | Pod [initContainers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) |
| deployment.labels | object | `{}` | Merges given labels with common labels |
| deployment.lifecycle | object | `{}` | Container [Lifecycle](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/) |
| deployment.livenessProbe | object | `{"exec":{"command":["/usr/bin/gobgp","neig"]}}` | Container [LivenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command) |
| deployment.nodeSelector | object | `{}` | Pod [NodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| deployment.podAnnotations | object | `{}` | Pod [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) are only added for the pod |
| deployment.podFields | object | `{}` | Add extra field to the [Pod Template](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podtemplate-v1-core) if not available as value. |
| deployment.podLabels | object | `{}` | Pod [labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) are only added for the pod |
| deployment.podSecurityContext | object | `{"fsGroup":2000,"runAsGroup":3000,"runAsUser":1000}` | Pod [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| deployment.ports | list | `[]` | Configure Container Ports |
| deployment.priorityClassName | string | `""` | Pod [priorityClassName](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass) |
| deployment.readinessProbe | object | `{"exec":{"command":["/usr/bin/gobgp","neig"]},"timeoutSeconds":30}` | Container [ReadinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes) |
| deployment.replicaCount | int | 1 | Amount of Replicas deployed |
| deployment.resources | object | `{"limits":{"cpu":"200m","memory":"218Mi"},"requests":{"cpu":"100m","memory":"25Mi"}}` | Configure Container [Resource](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| deployment.restartPolicy | string | `nil` | Restart policy for all containers within the pod. One of Always, OnFailure, Never. Default to Always. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy |
| deployment.securityContext | object | `{"allowPrivilegeEscalation":false}` | Container [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| deployment.selectorLabels | object | `{}` | Define SelectorLabels for the Pod Template |
| deployment.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| deployment.serviceAccount.apiVersion | string | v1 | Configure the api version used |
| deployment.serviceAccount.automountServiceAccountToken | bool | `true` | AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted. |
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
| deployment.volumeMounts | list | `[]` | Configure Container [volumeMounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/) |
| deployment.volumes | list | `[]` | Additional [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) |
| extraResources | list | `[]` | Enter Extra Resources managed by the Goblackhole Release |
| fullnameOverride | string | `""` | Overwrite `lib.utils.common.fullname` output |
| global.defaultTag | string | `""` | Global Docker Image Tag declaration. Will be used as default tag, if no tag is given by child |
| global.imagePullPolicy | string | `""` | Global Docker Image Pull Policy declaration. Will overwrite all child .pullPolicy fields. |
| global.imagePullSecrets | list | `[]` | Global Docker Image Pull Secrets declaration. Added to local Docker Image Pull Secrets. |
| global.imageRegistry | string | `""` | Global Docker Image Registry declaration. Will overwrite all child .registry fields. |
| global.storageClass | string | `""` | Global StorageClass declaration. Can be used to overwrite StorageClass fields. |
| goblackhole.config | object | `{}` | Configure Goblackhole (this will be written 1:1 to config.yaml) |
| kubeCapabilities | string | `$.Capabilities.KubeVersion.GitVersion` | Overwrite the Kube GitVersion |
| nameOverride | string | `""` | Overwrite "lib.internal.common.name" output |
| overwriteLabels | object | `{}` | Overwrites default labels, but not resource specific labels and common labels |
| selectorLabels | object | `{}` | Define default [selectorLabels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |

This Chart implements the Bedag Manifest Chart. Therefor there are a lot of values for you to play around.
