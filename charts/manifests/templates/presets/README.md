# Presets

Presets is a construct within this manifest library. It implements common declarations mode across different use-cases and chart layouts. Their purpose is the implement code reduction. Under the hood all presets use [this template](./../utils/README.md#presets) as wrapper.


# Components

Component Presets return a custom map with values you need to integrate with your chart. The map returned depends on the component.

## [JmxExporter](./components/_jmxexporter.tpl)

Returns a Prometheus [JMX Exporter Sidecar](https://github.com/prometheus/jmx_exporter) setup with all required components.

### [Values](../values/presets/components/_jmxexporter.yaml)

You can access the supported values for this preset clicking on values. These values represent the default values for this manifest.

### Manifests/Templates

Implements the following templates or manifests:

  * **[Container Template](./../manifests/README.md#container-template)**
  * **[Service](./../manifests/README.md#service)**
  * **[ServiceMonitor](./../manifests/README.md#servicemonitor)**
  * **[Raw](./../manifests/README.md#raw)**

### Usage

```
{{ include "bedag-lib.utils.presets" (dict "preset" "jmxexporter" "values" $.Values.jmxExporter "context" $) | nindent 0 }}
```

### Usage Output

```
container:
  name: jmx
  image: docker.io/bitnami/jmx-exporter:0.13.0-debian-10-r52
  imagePullPolicy:
  command:
    - java
    - -XX:+UnlockExperimentalVMOptions
    - -XX:+UseCGroupMemoryLimitForHeap
    - -XX:MaxRAMFraction=1
    - -XshowSettings:vm
    - -jar
    - jmx_prometheus_httpserver.jar
    - "5556"
    - /opt/jmx-config/jmx-prometheus.yml
  volumeMounts:
    - mountPath: /opt/jmx-config
      name: jmx-config
  ports:
    - containerPort: 5556
      name: jmx

ports:
  - containerPort: 5555
    name: "jmx"
    protocol: TCP
volumes:
  - name: "jmx-config"
    configMap:
      name: release-name-jmx

extraResources:
  - type: "raw"
    manifest: |
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: release-name-jmx
        labels:
          app.kubernetes.io/component: metrics
          app.kubernetes.io/instance: RELEASE-NAME
          app.kubernetes.io/name: jira-software
          app.kubernetes.io/version: 8.13.0
          manifests.bedag/component: jmx
      data:
        jmx-prometheus.yml: |-
          jmxUrl: service:jmx:rmi:///jndi/rmi://127.0.0.1:5555/jmxrmi
          lowercaseOutputLabelNames: true
          lowercaseOutputName: true
          ssl: false
  - type: "service"
    name: jmx
    values:
      annotations:
        prometheus.io/path: /
        prometheus.io/port: "5556"
        prometheus.io/scrape: "true"
      apiVersion: ""
      enabled: true
      extraPorts: []
      labels:
        app.kubernetes.io/component: metrics
        manifests.bedag/component: jmx
      loadBalancerIP: ""
      loadBalancerSourceRanges: []
      nodePort: ""
      port: "5556"
      portName: metrics
      selector: {}
      targetPort: "5556"
      type: ClusterIP
  - type: "servicemonitor"
    name: jmx
    values:
      additionalFields: {}
      apiVersion: ""
      enabled: true
      endpoints:
      - interval: 10s
        path: /
        port: metrics
        scrapeTimeout: 10s
      labels:
        app.kubernetes.io/component: metrics
        manifests.bedag/component: jmx
      namespace: ""
      namespaceSelector: []
      selector:
        manifests.bedag/component: jmx
```

#### Extended example

Since only a map is returned, you need to merge/use those values in your bundle/manifest:

```

{{- define "chart.bundle" -}}
resources:
  {{- if $.Values.extraResources }}
    {{- toYaml $.Values.extraResources | nindent 2 }}
  {{- end }}

  {{ $jmxExporter := (fromYaml (include "bedag-lib.utils.presets" (dict "preset" "jmxexporter" "values" $.Values.jmxExporter "context" $))) }}
  {{- if $jmxExporter.extraResources }}
    {{- toYaml $jmxExporter.extraResources | nindent 2 }}
  {{- end }}

  - type: "statefulset"
    values: {{ toYaml $.Values.statefulset | nindent 6 }}
    overwrites:

      {{/*
        Predefined Ports
      */}}
      {{- if or $.Values.statefulset.ports $jmxExporter.ports }}      
      ports:
        {{- if $.Values.statefulset.ports }}
          {{- toYaml $.Values.statefulset.ports | nindent 8 }}
        {{- end }}
        {{- if $jmxExporter.ports }}
          {{- toYaml $jmxExporter.ports | nindent 8 }}
        {{- end }}
      {{- end }}  

      {{/*
        Predefined Statefulset Volumes
      */}}
      {{- if or $.Values.statefulset.volumes $jmxExporter.volumes }}
      volumes:
        {{- if $.Values.statefulset.volumes }}
          {{- toYaml $.Values.statefulset.volumes | nindent 8 }}
        {{- end }}
        {{- if $jmxExporter.volumes }}
          {{- toYaml $jmxExporter.volumes | nindent 8 }}
        {{- end }}
      {{- end }}

      {{/*
        Predefined Statefulset Sidecars
      */}}
      {{- if or $jmxExporter.container $.Values.statefulset.sidecars }}
      sidecars:
        {{- if $jmxExporter.container }}
        - {{- toYaml $jmxExporter.container | nindent 10 }}
        {{- end }}
        {{- if $.Values.statefulset.sidecars }}
          {{- toYaml $.Values.statefulset.sidecars | nindent 8 }}
        {{- end }}
      {{- end }}

```


# Containers

Container Presets just return a container definition.

## [Permissions](./containers/_permissions.tpl)

Generates a simple container which's purpose is to change directories permissions/owner. Mostly used as initContainer to correct permissions of external volumes.

### [Values](../values/presets/containers/_permissions.yaml)

You can access the supported values for this preset clicking on values. These values represent the default values for this manifest.

### Manifests/Templates

Implements the following templates or manifests:

  * **[Container Template](./../manifests/README.md#container-template)**

### Usage

```
initContainers: {{ include "bedag-lib.utils.presets" (dict "preset" "permissions" "values" $.Values.volumePermissions "returnAsArray" true "context" $) | nindent 2 }}
```

### Usage Output

```
initContainers:
  -
    name: permissions
    image: docker.io/bitnami/minideb:buster
    imagePullPolicy:
    securityContext:
    runAsUser: 0
    command:
    - /bin/bash
    args:
    - -ec
    - |
     chown -R 0:0 /tmp
```

#### Extended example

Here's a little bit more complex but reliable example of preset usage:

```
{{- define "chart.volumePermission.values" }}
  {{- if $.Values.chart.clustered }}
enabled: true
volumeMounts:
    {{- if $.Values.volumePermissions.volumeMounts }}
      {{- toYaml $.Values.volumePermissions.volumeMounts | nindent 2 }}
    {{- end }}
    {{- if $.Values.chart.clustered }}
  - name: shared
    mountPath: /chart/data
    {{- end }}
  {{- else }}
enabled: false
  {{- end }}
{{- end }}

{{- define "chart.bundle" -}}
resources:
  - type: "statefulset"
    values: {{ toYaml .Values.statefulset | nindent 6 }}
    overwrites:
      initContainers:
        {{- if and $.Values.statefulset.initContainers (kindIs "slice"   $.Values.statefulset.initContainers) }}
          {{- toYaml $.Values.statefulset | nindent 8 }}
        {{- end }}
        {{ include "bedag-lib.utils.presets" (dict "preset" "permissions" "values" (mergeOverwrite   $.Values.volumePermissions (fromYaml (include "chart.volumePermission.values" $))) "returnAsArray"   true "context" $) | nindent 8 }}

  ....
{{- end -}}        
```

## Readiness

Generates a simple container containing a bash script, which checks an endpoint for given status codes or readiness. Commonly used as initContainer for instances, which depend on another instance's readiness.

### [Values](../values/presets/containers/_readiness.yaml)

You can access the supported values for this preset clicking on values. These values represent the default values for this manifest.

### Manifests/Templates

Implements the following templates or manifests:

  * **[Container Template](./../manifests/README.md#container-template)**

### Usage

```
initContainers: {{ include "bedag-lib.utils.presets" (dict "preset" "readiness" "values" (dict "enabled" true "url" "https://google.com") "context" $) | nindent 2 }}
```

### Usage Output

```
initContainers:
  -
    name: readiness
    image: docker.io/curlimages/curl:8.13.0
    imagePullPolicy:
    securityContext:
      runAsUser: 0
    command:
      - /bin/sh
    args:
      - -ec
      - |
        #!/bin/bash
        URL="https://google.com"
        STATUS_CODES=( "200" )
    .....    
```
