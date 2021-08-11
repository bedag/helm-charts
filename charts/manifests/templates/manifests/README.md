# Overview

In the following sections we explain how to use the manifest.

  * **[Bundles](#bundles)**
  * **[Manifest Templates](#manifest-templates)**
  * **[Templates](#resource-templates)**
  * **[Examples](#examples)**

Don't forget to take a look at Presets as well:

  * **[Presets](../presets/README.md)**

# Bundles

We recommend using Bundles. A Bundle describes a list of resources you want to render together your chart. This allows you to implement resource Grouping within your Helm Chart. A bundle returns a kubernetes list with all the given resources rendered, which then can be applied to the kubernetes API. Each chart can have n amount of bundles. This construct was designed to improve code visibility.

## Arguments

- `.bundle` - Supported bundle structure, see below (Required).
- `.context` - Inherited Root Context (Required)

## Structure

The following structure is used to define a bundle:

```
name: ""
common: {}
resources: []
```

Explanation of the above keys:

  - `.name` - Sets a name for the entire bundle (bundlename). Each resource will use the bundlename as prefix, when using the `bedag-lib.fullname` template (Optional).
  - `.common` - Allows to overwrite the given `.context`. With this functionality you can influence values which aren't scoped on a single resource but the entire chart (Optional).
  - `.resources` - A list of resources you want to have included in this bundle. To see how declare resources, [see resource types](#resource-types) (Required).


## Usage

We recommend creating a dedicated template within your chart just for the bundle structure. This structure should then be used to call the bundle template, like so:

```
{{/*
  Bundle Inclusion
*/}}
{{- include "bedag-lib.manifest.bundle" (dict "bundle" (fromYaml (include "custom.bundle" $)) "context" $) | nindent 0 }}

{{/*
  Bundle Definition
*/}}
{{- define "custom.bundle" -}}
name: "frontend"
common:
  commonLabels:
    "custom-chart-label": "1"
resources:
  {{- if .Values.extraResources }}
    {{- toYaml .Values.extraResources | nindent 2 }}
  {{- end }}
  - type: "statefulset"
    values: {{ toYaml .Values.statefulset | nindent 6 }}
    overwrites:
      {{- if .Release.IsInstall }}
      replicaCount: 1
      {{- end }}
  - type: "service"
    name: "headless"
    values {{ toYaml .Values.service | nindent 6 }}  
{{- end }}
```
### Explicit Bundle

If you have a single bundle, you can just declare the bundle with `chart.bundle` to keep complexity lower. Like this:

```
{{- include "bedag-lib.manifest.bundle" $ | nindent 0 }}
{{- define "chart.bundle" -}}
name: "frontend"
common:
  commonLabels:
    "custom-chart-label": "1"
resources:
  {{- if .Values.extraResources }}
    {{- toYaml .Values.extraResources | nindent 2 }}
  {{- end }}
  - type: "statefulset"
    values: {{ toYaml .Values.statefulset | nindent 6 }}
    overwrites:
      {{- if .Release.IsInstall }}
      replicaCount: 1
      {{- end }}
  - type: "service"
    name: "headless"
    values {{ toYaml .Values.service | nindent 6 }}  
{{- end }}
```

Recommended if you just need one bundle in your chart.

## Resource Types

All manifests below are supported as **type**. Refer to the examples below to see how it is done. There's only one extra resource available with bundles.

To declare a resource you can use these keys:

  * `.type` - Enter the name of the manifest you want to render. If not set this item will be skipped (Required). The manifest must be [supported by the library](#manifest-templates) otherwise it will be skipped.
  * `name` - Define a custom name for the resource. If this field is set and the above name, the name on item basis takes precedence. This name won't do a full overwrite (Optional).
  * `fullname` - Define a custom name with will full overwrite the resource name. Meaning the given name, will be the exact name of the resource (Optional).
  * `.values` - Render the corresponding values for the manifest. Values will be merged over the manifests default values (Optional).
  * `.overwrites` - Values which overwrite the values given to `.values` and default values. This should be mainly used to implement logic/overwrites for values (Optional)

A simple example was already shown in the Usage of bundles.
[See the Examples](#examples) to get an idea how to resources in a more complex layout.

### Raw

Bundles allow the definition of raw resources. Raw resources are just raw yamls which are rendered together with the rest of the bundle. Make sure it's a valid Kubernetes Manifest per-se.

If you want to declare a raw resource, the element must be of type **raw** and requires the field **manifest**. If not provided, the element will be skipped. The raw manifest does not support the _name_, _fullname_ and _override_ field. See the following example for reference

```
resources:

  - type: "raw"
    manifest: |
      apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: {{ cat (include "bedag-lib.fullname" $) "-export" | nospace }}
        annotations:
         "helm.sh/hook": pre-install
      spec:
        accessModes: [ "ReadWriteMany" ]
        resources:
          requests:
            storage: "20Gi"
        storageClassName: "nfs-share"
```

This can be useful when adding CRDs or appending lose Kubernetes Resources to a release (By Chart User).


## [Extras](./templates/_bundleExtras.tpl)

There are some extras/functionalities, which are only enabled when using a resource in a bundle. Getting the resource just by it's manifest template won't allow the functionality.

### ServiceAccount

Allows to directly create a serviceAccount without having to declare it as dedicated resource. The serviceAccount is returned as dedicated resource as part of the kubernetes list.

#### Affects

All resources

#### Structure

See ServiceAccount Values.

### Environment Secrets

Environment secrets allows to directly add secrets from the environment declaration. Secret Key's values will be encoded into a secret and mounted to the environment.

#### Affects

All resources

#### Structure

This template supports the following key structure:

```
environment:

# Environment Variables
- name: "MY_ENV"
  value: "someValue"
- name: "MY_SPEC"
  valueFrom:
   fieldRef:
     fieldPath: spec.*

# Secret Environment Variables
- name: "MY_SECRET"
  value: "S3CRET"
  secret: true

```

**Note:** Secret Environment variables are only supported/rendered if the resource is part of a bundle. If the resource is not part of a bundle the secrets are removed, to prevent exposing them.

# Manifest Templates

With the Manifest templates you have the possibility to get a single resource. The layout is controlled by the values given to it. So there's a lot of flexibility built in for you to play with.

**Manifests**

Currently we support the following Kubernetes Manifests:

  * **[Cronjob](#cronjob)**
  * **[DaemonSet](#daemonset)**
  * **[Deployment](#deployment)**
  * **[HorizontalPodAutoscaler](#horizontalpodautoscaler)**
  * **[Ingress](#ingress)**
  * **[Job](#job)**
  * **[PersistentVolumeClaim](#persistentvolumeclaim)**
  * **[Pod](#pod)**
  * **[PodDisruptionBudget](#poddisruptionbudget)**
  * **[Service](#service)**
  * **[ServiceAccount](#serviceaccount)**                  
  * **[Statefulset](#statefulset)**


## Cronjob

This Template returns a [Cronjob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_cronjob.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[Job Template](#job-template)**

### Usage

```
{{ include "bedag-lib.manifest.cronjob" (dict "values" $.Values.cronjob "fullname" "custom-cronjob" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "cronjob"
    values: {{ toYaml $.Values.cronjob | nindent 6 }}
    fullname: "custom-cronjob"
  ...
```

## DaemonSet

This Template returns a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/daemonset.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[Pod Template](#pod-template)**

### Usage

```
{{ include "bedag-lib.manifest.daemonset" (dict "values" $.Values.daemonset "fullname" "custom-daemonset" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "daemonset"
    values: {{ toYaml $.Values.daemonset | nindent 6 }}
    fullname: "custom-daemonset"
  ...
```

## Deployment

This Template returns a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_deployment.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[Pod Template](#pod-template)**

### Usage

```
{{ include "bedag-lib.manifest.deployment" (dict "values" $.Values.deployment "fullname" "custom-deployment" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "deployment"
    values: {{ toYaml $.Values.deployment | nindent 6 }}
    fullname: "custom-deployment"
  ...
```

## HorizontalPodAutoscaler

This Template returns a [HorizontalPodAutoscaler](https://kubernetes.io/de/docs/tasks/run-application/horizontal-pod-autoscale/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_horizontalPodAutoscaler.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Does not implement any templates.

### Usage

```
{{ include "bedag-lib.manifest.horizontalpodautoscaler" (dict "values" $.Values.autoscaler "fullname" "custom-hpa" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "horizontalPodAutoscaler"
    values: {{ toYaml $.Values.autoscaler | nindent 6 }}
    fullname: "custom-hpa"
  ...
```

## Ingress

This Template returns a [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_ingress.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Does not implement any templates.

### Usage

```
{{ include "bedag-lib.manifest.ingress" (dict "values" $.Values.ingress "fullname" "custom-ing" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "ingress"
    values: {{ toYaml $.Values.ingress | nindent 6 }}
    fullname: "custom-ing"
  ...
```

## Job

This Template returns a [Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_job.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[Job Template](#job-template)**

### Usage

```
{{ include "bedag-lib.manifest.job" (dict "values" $.Values.job "fullname" "custom-job" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "job"
    values: {{ toYaml $.Values.job | nindent 6 }}
    fullname: "custom-job"
  ...
```

## PersistentVolumeClaim

This Template returns a [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_persistentVolumeClaim.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[PVC Template](#pvc-template)**

### Usage

```
{{ include "bedag-lib.manifest.persistentvolumeclaim" (dict "values" $.Values.pvc "fullname" "custom-pvc" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "persistentvolumeclaim"
    values: {{ toYaml $.Values.pvc | nindent 6 }}
    fullname: "custom-pvc"
  ...
```

## Pod

This Template returns a [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_pod.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[Pod Template](#pod-template)**

### Usage

```
{{ include "bedag-lib.manifest.pod" (dict "values" $.Values.pod "fullname" "custom-pod" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "pod"
    values: {{ toYaml $.Values.pod | nindent 6 }}
    fullname: "custom-pod"
  ...
```

## PodDisruptionBudget

This Template returns a [PodDisruptionBudget](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_podDisruptionBudget.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Does not implement any templates.

### Usage

```
{{ include "bedag-lib.manifest.poddisruptionbudget" (dict "values" $.Values.pdb "fullname" "custom-pdb" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "podDisruptionBudget"
    values: {{ toYaml $.Values.pdb | nindent 6 }}
    fullname: "custom-pdb"
  ...
```

## Service

This Template returns a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_service.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Does not implement any templates.

### Usage

```
{{ include "bedag-lib.manifest.service" (dict "values" $.Values.service "fullname" "custom-svc" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "service"
    values: {{ toYaml $.Values.service | nindent 6 }}
    fullname: "custom-svc"
  ...
```

## ServiceAccount

This Template returns a [ServiceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_serviceAccount.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Does not implement any templates.

### Usage

```
{{ include "bedag-lib.manifest.serviceaccount" (dict "values" $.Values.sa "fullname" "custom-sa" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "serviceaccount"
    values: {{ toYaml $.Values.sa | nindent 6 }}
    fullname: "custom-sa"
  ...
```

## ServiceMonitor

This Template returns a [ServiceMonitor](https://docs.openshift.com/container-platform/4.4/rest_api/monitoring_apis/servicemonitor-monitoring-coreos-com-v1.html) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_serviceMonitor.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Does not implement any templates.

### Usage

```
{{ include "bedag-lib.manifest.servicemonitor" (dict "values" $.Values.serviceMonitor "fullname" "custom-sm" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "servicemonitor"
    values: {{ toYaml $.Values.serviceMonitor | nindent 6 }}
    fullname: "custom-sm"
  ...
```

## Statefulset

This Template returns a [Statefulset](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset//) Kubernetes Manifest.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.overwrites` - Supported key structure overwriting the structure given to `.values` (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/_statefulset.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[Pod Template](#pod-template)**

### Usage

```
{{ include "bedag-lib.manifest.statefulset" (dict "values" $.Values.statefulset "fullname" "custom-sts" "context" $) }}
```

#### With Bundle

```
resources:
  ...
  - type: "statefulset"
    values: {{ toYaml $.Values.statefulset | nindent 6 }}
    fullname: "custom-sts"
  ...
```

# Resource Templates

Templates might be used with multiple resources, to achieve code reduction and keep maintainability simple. You might as well be able to make use of these templates. The approach is somehow the same as with rendering kubernetes manifests. The difference is, the resulting structures from templates are not directly a kubernetes manifest, they might be a part of it. Templates can't be directly part of a bundle (it's not a `type`).

## Container Template

Template renders a container structure, reusable for `sideCars`, `initContainers` or `whatever you like`.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.container` - Supported values structure for this template (See below). Will be merged over the default values for this template (Optional).
  * `.name` - Partial name for the template, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the template, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/templates/_containerTpl.yaml)

You can access the supported values for this template through clicking on values. These values represent the default values for this template.

### Templates

Does not implement any templates.

### Usage

```
{{ include "bedag-lib.template.container" (dict  "container" $.Values.extraContainer "context" $) }}
```

## Job Template

Template renders a job structure without `kind` and `apiVersion`.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.job` - Supported values structure for this template (See below). Will be merged over the default values for this template (Optional).
  * `.name` - Partial name for the template, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the template, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/templates/_jobTpl.yaml)

You can access the supported values for this template through clicking on values. These values represent the default values for this template.

### Templates

Implements the following templates:

  * **[Pod Template](#pod-template)**

### Usage

```
{{ $cleanup := fromYaml (include "bedag-lib.template.job" (dict  "name" "cleanup-job" "job" $.Values.cleanup "context" $)) }}
```

## Pod Template

Template renders a pod structure without `kind` and `apiVersion`.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.pod` - Supported values structure for this template (See below). Will be merged over the default values for this template (Optional).
  * `.name` - Partial name for the template, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the template, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/templates/_podTpl.yaml)

You can access the supported values for this template through clicking on values. These values represent the default values for this template.

### Templates

Implements the following templates:

  * **[Container Template](#container-template)**

### Usage

```
{{ $body := fromYaml (include "bedag-lib.template.pod" (dict  "name" "body" "pod" $.Values.statefulset "context" $)) }}
```

## PVC Template

Template renders a pvc structure without `kind` and `apiVersion`.

### Arguments

The following arguments are supported for this template. If a required argument is not given, the template will fail or return empty.

  * `.pvc` - Supported values structure for this template (See below). Will be merged over the default values for this template (Optional).
  * `.name` - Partial name for the template, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.fullname` - Full name for the template, influences the result of the `bedag-lib.fullname` template (Optional).
  * `.context` - Inherited Root Context (Required)

### [Values](../values/manifests/templates/_pvcTpl.yaml)

You can access the supported values for this template through clicking on values. These values represent the default values for this template.

### Templates

Does not implement any templates.

### Usage

```
{{ include "bedag-lib.template.pvc" (dict "pvc" $.Values.persistence "context" $) | nindent 2 }}
```

# Examples

See the following examples to get a better understanding of how you can use the manifest library. In the examples are no value structure documented. We are assuming that under there referenced key are the default keys for each manifest (generated by the values generator). Your creativity is the limit! :)

We are implementing structure using these structures with most charts hosted in this repository. So take a look at other charts for reference.

## Simple Bundle

Here's a simple example using a single bundle. You need a single file the implement all your resources and chart logic.

**templates/bundle.yaml**
```
{{- include "bedag-lib.manifest.bundle" (dict "bundle" (fromYaml (include "chart.bundle" $)) "context" $) | nindent 0 }}

{{- define "chart.bundle" }}
common:
  commonLabels:
    app.kubernetes.io/component: "frontend"
resources:
  - type: "statefulset"
    values: {{ toYaml .Values.statefulset | nindent 6 }}
  - type: "service"
    values: {{ toYaml .Values.service | nindent 6 }}
  - type: "service"
    values: {{ toYaml .Values.headless | nindent 6 }}
    name: "headless"
  - type: "ingress"
    values: {{ toYaml .Values.ingress | nindent 6 }}
    overwrites:
      annotations:
        nginx.ingress.kubernetes.io/affinity:  cookie
        nginx.ingress.kubernetes.io/session-cookie-max-age: "10800"
  {{- if and .Values.pdb (gt (int .Values.statefulset.replicaCount) 1) }}
  - type: "poddisruptionbudget"
    values: {{ toYaml .Values.pdb | nindent 6 }}
  {{- end }}
  {{- if .Values.persistence }}
    {{- if .Values.persistence.enabled }}
  - type: "persistentvolumeclaim"
    values: {{ toYaml .Values.persistence | nindent 6 }}
    {{- end }}
  {{- end }}
{{- end }}
```

#### Multiple Bundles

Using multiple bundles is very straightforward, just do the same thing you did with a single bundle but multiple times - that's it. In this example we separate two microservices within the chart (Frontend/Backend).

**templates/frontend.yaml**
```
{{- include "bedag-lib.manifest.bundle" (dict "bundle" (fromYaml (include "chart.bundle.frontend" $)) "context" $) | nindent 0 }}

{{- define "chart.bundle.frontend" }}
name: "frontend"
common:
  commonLabels:
    app.kubernetes.io/component: "frontend"
resources:
- type: "deployment"
  values: {{ toYaml .Values.frontend.deployment | nindent 6 }}
- type: "service"
  values: {{ toYaml .Values.frontend.service | nindent 6 }}
- type: "ingress"
  values: {{ toYaml .Values.frontend.ingress | nindent 6 }}
{{- end }}
```

**templates/backend.yaml**
```
{{- include "bedag-lib.manifest.bundle" (dict "bundle" (fromYaml (include "chart.bundle.backend" $)) "context" $) | nindent 0 }}

{{- define "chart.bundle.backend" }}
name: "backend"
common:
  commonLabels:
    app.kubernetes.io/component: "backend"
resources:
  - type: "statefulset"
    values: {{ toYaml .Values.statefulset | nindent 6 }}
  - type: "service"
    values: {{ toYaml .Values.service | nindent 6 }}
  - type: "service"
    values: {{ toYaml .Values.headless | nindent 6 }}
    name: "headless"
  {{- if .Values.persistence }}
    {{- if .Values.persistence.enabled }}
  - type: "persistentvolumeclaim"
    values: {{ toYaml .Values.persistence | nindent 6 }}
    {{- end }}
  {{- end }}
{{- end }}
```
