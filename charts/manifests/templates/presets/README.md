# Presets

Presets is a construct within this manifest library. It implements common declarations mode across different use-cases and chart layouts. Their purpose is the implement code reduction. Under the hood all presets use [this template](./../utils/README.md#presets) as wrapper.

## Permissions

Generates a simple container whichs purpose is to change directories permissions/owner. Mostly used as initContainer to correct permissions of external volumes.

### [Values](../values/presets/_permissions.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[Container Template](./../manifests/README.md#container-template)**

### Usage

```
initContainers: {{ include "bedag-lib.presets" (dict "preset" "permissions" "values" $.Values.volumePermissions "returnAsArray" true "context" $) | nindent 2 }}
```

### Example Output

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

#### Extended exmaple

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
        {{ include "bedag-lib.presets" (dict "preset" "permissions" "values" (mergeOverwrite   $.Values.volumePermissions (fromYaml (include "chart.volumePermission.values" $))) "returnAsArray"   true "context" $) | nindent 8 }}

  ....
{{- end -}}        
```

## Readiness

Generates a simple container containing a bash script, which checks an endpoint for given status codes or readiness. Commonly used as initContainer for instances, which depend on another instance's readiness.

### [Values](../values/presets/_readiness.yaml)

You can access the supported values for this kubernetes manifest through clicking on values. These values represent the default values for this manifest.

### Templates

Implements the following templates:

  * **[Container Template](./../manifests/README.md#container-template)**

### Usage

```
initContainers: {{ include "bedag-lib.presets" (dict "preset" "readiness" "values" (dict "enabled" true "url" "https://google.com") "context" $) | nindent 2 }}
```

### Example Output

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
