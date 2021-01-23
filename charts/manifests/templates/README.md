# Development

Here you find some documentation on how to add manifests or components to the library or expanding it by yourself.

## Add Preset

A preset is an implementation of a manifest/template for a very specific use case. Let's see how we add a new preset. Let's add a new preset, which is called `says` and just renders a container with an echo. First we create the main file:

**templates/presets/containers/_says.tpl**

```
{{/*
  Preset Say - Template Inclusion

  Here's defined what's returned from the preset. In this use case we want to return a container
  template

  Make sure:
    * Has **bedag-lib.presets** as prefix
    * Manifest is written in all lower case (**says**)  
*/}}
{{- define "bedag-lib.presets.says" -}}
  {{- if and .values .context }}
    {{- if .values.enabled }}
      {{- $_ := set . "container" .values }}
{{- include "bedag-lib.template.container" . }}
      {{- $_ := unset . "container" }}
    {{- end }}
  {{- else }}
    {{- fail "Module requires '.module' and '.context' in the key structure" }}
  {{- end }}
{{- end -}}


{{/*
  Preset Say - Overwrite Values

  These values will overwrite all the other values given as input. Effectively implementing
  the logic for the use case.The given values (defaults merged with user input) are available
  under the .values key.

  Make sure:
    * Has **bedag-lib.presets** as prefix
    * Manifest is written in all lower case (**says**)  
    * Has **overwrites** as suffix
*/}}
{{- define "bedag-lib.presets.says.overwrites" -}}
containerName: {{ default "says" .name }}
command:
  - /bin/bash
args:
  - -ec
  - |
    echo "{{ .values.says }}"
{{- end }}

```

The default values for this preset go here:

**templates/values/presets/_says.yaml**

```
{{- define "bedag-lib.presets.values.says" -}}
  {{- $context := (default $ .context) }}
  {{- $_ := dict "path" (default $context.path .path) "context" $context "data" (default dict .data) "minimal" (default false .minimal) }}
## Says Enable
# {{ $_.path }}enabled -- Enables Says
enabled: false

## Says Context
# {{ $_.path }}enabled -- Says what?
says: "hello"

## Container Template Values
## We directly overwrite the image, since we don't want the apache image (default). The user still
## has the option to overwrite the image with his own.

## Container Configuration
## {{ include "bedag-lib.intern.docLink" $ }}#container-template
  {{- if $_.minimal }}
## Supports all the values from the referenced template. Find all available values in the link above.
  {{- else }}
## Full Configuration
    {{- $o := set $_.data (mergeOverwrite $_.data (dict "imageRepository" "bash")) }}
    {{- include "bedag-lib.values.template.container" $_ | nindent 0 }}
  {{- end }}
{{- end -}}
```

Now let's see if that worked:

```
{{ include "bedag-lib.presets" (dict "preset" "says" "values" (dict "enabled" true "says" "MEOW! =^.^⁼") "context" $) | nindent 2 }}
```

Executing the template should give me something like this:

```
name: says
image: docker.io/bash:1.16.0
imagePullPolicy:
command:
  - /bin/bash
args:
  - -ec
  - echo "MEOW! =^.^⁼"
```

Seems like it worked! You can do this with any number of manifests etc. you can even return multiple resources with a kubernetes list, everything is up to you.

## Add Manifest/Expanding the Chart

The workflow for expanding the chart and adding a manifest is kind of the same, therefor the following documentation is for both scenarios. Same goes for presets.

There might be the use case, that you have resources that you may want to add to the manifest library but they are just for your use-case. In this case you would also have the possibility to extend the manifest library. Let us show you how you can do this, with a very simple example:

So assuming that I need lots of Prometheus ServiceMonitors, I would like to add them as manifest. After I have created a new chart and marked the manifest library chart as dependency, I can get started. I would also like my ServiceMonitor to work with bundles.

First i am creating the main file (do whatever structure you like, just make sure you have all the templates required, that's just a proposal from our side):

**templates/manifests/_serviceMonitor.yaml**

```
{{/*
  Here's the heart of our manifest. Basically here you design what's going to be returned as manifest.
  Make Sure:
    * Has **bedag-lib.manifest** as prefix
    * Manifest is written in all lower case (**servicemonitor**)  
*/}}
{{- define "bedag-lib.manifest.servicemonitor" -}}
  {{- if .context -}}
    {{- $context := .context -}}
      {{- $serviceMonitor := mergeOverwrite (fromYaml (include "bedag-lib.values.servicemonitor" $)).serviceMonitor (default dict .values) (default dict .overwrites) -}}
      {{- if (include "bedag-lib.utils.intern.noYamlError" $serviceMonitor) }}
        {{- if $serviceMonitor.enabled -}}
          {{- if $serviceMonitor.apiVersion -}}
apiVersion: {{ $serviceMonitor.apiVersion }}
          {{- else -}}
apiVersion: monitoring.coreos.com/v1
          {{- end }}
kind: ServiceMonitor
metadata:
  name:  {{ include "bedag-lib.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $serviceMonitor.labels "context" $context)| nindent 4 }}
          {{- if $serviceMonitor.namespace }}
  namespace: {{ $serviceMonitor.namespace }}
          {{- end }}
spec:
          {{- if $serviceMonitor.additionalFields }}
            {{- toYaml $serviceMonitor.additionalFields | nindent 2 }}
          {{- end }}
  selector:
    matchLabels:
  endpoints: {{- include "lib.utils.strings.template" (dict "value" $serviceMonitor.endpoints "context" $context) | nindent 4 }}
  namespaceSelector:
    matchNames:
          {{- if $serviceMonitor.namespaceSelector }}
            {{- if kindIs "slice" $serviceMonitor.namespaceSelector }}
              {{- toYaml $serviceMonitor.namespaceSelector | nindent 6 }}
            {{- else }}
      - {{ $serviceMonitor.namespaceSelector }}
            {{- end }}
          {{- else }}
      - {{ $context.Release.Namespace }}
          {{- end }}
        {{- end }}  
      {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end -}}
```

We recommend adding default values for each manifest, these can be used as referenced and also integrated with the values generator.

**templates/values/_serviceMonitor.yaml**
```
{{- define "bedag-lib.values.servicemonitor" -}}
  {{- $context := (default $ .context) }}
  {{- $_ := dict "parentKey" (default "serviceMonitor" .key) "path" (cat (default "" (default $context.path .path)) (default "serviceMonitor" .key) "." | nospace) "context" $context "data" (default dict .data) "minimal" (default false .minimal) }}
#
## - ServiceMonitor
## Reference: https://docs.openshift.com/container-platform/4.4/rest_api/monitoring_apis/servicemonitor-monitoring-coreos-com-v1.html
## ServiceMonitor API Object - https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#servicemonitorspec
##
{{ $_.parentKey }}:

  ## Enable ServiceMonitor
  # {{ $_.path }}enabled -- Enable serviceMonitor Resource
  enabled: true

  ## ServiceMonitor API version
  # {{ $_.path }}apiVersion -- Configure the api version used for the ServiceMonitor resource
  apiVersion: ""

  ## ServiceMonitor Namespace
  ## {{ $_.path }}namespace -- Define the namespace to deploy the serviceMonitor in
  namespace: ""

  ## ServiceMonitor NamespaceSelector
  # {{ $_.path }}namespaceSelector -- Define which Namespaces to watch. Can either be type string or slice
  # @default -- `$.Release.Namespace`
  namespaceSelector: []

  ## ServiceMonitor Additional Fields
  # {{ $_.path }}additionalFields -- Define additional fields, which aren't available as separat key (e.g. `sampleLimit`)
  additionalFields: {}

  ## ServiceMonitor Endpoint Configuration
  # {{ $_.path }}endpoints -- Configure Prometheus ServiceMonitor [Endpoints](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#endpoint)
  endpoints: {}
  #  - port: metrics
  #    path: "/"
  #    interval: 10s
  #    scrapeTimeout: 10s

  ## ServiceMonitor labels
  # {{ $_.path }}labels -- Configure Prometheus ServiceMonitor labels
  labels: {}

  ## ServiceMonitor Selector Configuration
  # {{ $_.path }}selector -- Configure Prometheus ServiceMonitor Selector
  # @default -- `bedag-lib.selectorLabels`
  selector: {}
{{- end -}}
```

Now let's test if this worked. Just creating a simple bundle for testing purposes:

**templates/bundle.yaml**

```
{{- include "bedag-lib.manifest.bundle" (dict "bundle" (fromYaml (include "sample.bundle" $)) "context" $) | nindent 2 }}
{{- define "sample.bundle" -}}
resources:
  - type: "serviceMonitor"
    name: "sm"
    values:
      endpoints:
      - interval: 15s
        path: /metrics
        targetPort: 8000
  - type: "serviceMonitor"
    fullname: "full-sm"
    values:
      endpoints:
        - interval: 15s
          path: /metrics
          targetPort: 8000
{{- end }}
```

Should get you something like this:

```
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name:  tess-sm
  labels:
    app.kubernetes.io/instance: test
    app.kubernetes.io/name: expand
    app.kubernetes.io/version: 1.16.0
spec:
  selector:
    matchLabels:
  endpoints:
    - interval: 15s
      path: /metrics
      targetPort: 8000
  namespaceSelector:
    matchNames:
      - default
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name:  full-sm
  labels:
    app.kubernetes.io/instance: test
    app.kubernetes.io/name: expand
    app.kubernetes.io/version: 1.16.0
spec:
  selector:
    matchLabels:
  endpoints:
    - interval: 15s
      path: /metrics
      targetPort: 8000
  namespaceSelector:
    matchNames:
      - default
```

Wow! Seems to work perfectly! How are you so good? If you are having trouble, please open an issue, we are happy to help.
