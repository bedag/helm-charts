{{/*

Copyright © 2021 Bedag Informatik AG

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/}}
{{/*
  Preset - Template Inclusion
*/}}
{{- define "bedag-lib.presets.jmxexporter" -}}
  {{- if and $.values $.context }}
    {{- if $.values.enabled }}
      {{- $name := (include "lib.utils.strings.toDns1123" $.values.name) }}
      {{- $_ := set . "container" .values }}
container: {{- include "bedag-lib.template.container" (set . "container" .values) | nindent 2 }}
      {{- $_ := unset . "container" }}

ports:
  - containerPort: {{ $.values.targetPort }}
    name: "{{ $name }}"
    protocol: TCP
      {{- if $.values.config }}
volumes:
  - name: "{{  $name }}-config"
    configMap:
      name: {{ include "bedag-lib.utils.common.fullname" (dict "name" $name "context" $.context) }}
      {{- end }}

extraResources:
      {{- if $.values.config }}
  - type: "raw"
    manifest: |
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: {{ include "bedag-lib.utils.common.fullname" (dict "name" $name "context" $.context) }}
        labels: {{- include "lib.utils.common.labels" (dict "labels" $.values.labels "context" $.context) | nindent 10 }}
          manifests.bedag/component: {{ $name }}
      data:
        jmx-prometheus.yml: |-
          {{- include "lib.utils.strings.template" (dict "value" $.values.config "context" $.context) | nindent 10 }}
      {{- end }}
      {{- if $.values.service.enabled }}
  - type: "service"
    name: {{ $name }}
    values: {{ toYaml $.values.service | nindent 6 }}
      {{- end }}
  - type: "servicemonitor"
    name: {{ $name }}
    values: {{ toYaml $.values.serviceMonitor | nindent 6 }}
    {{- end }}
  {{- end }}
{{- end }}


{{/*
  Preset - Overwrite Values
*/}}
{{- define "bedag-lib.presets.jmxexporter.overwrites" -}}
  {{- $name := (include "lib.utils.strings.toDns1123" $.values.name) }}

  ## JMX Configuration
  {{- $config := $.values.config }}
  {{- if (kindIs "string" $.values.config)}}
    {{- $config = (fromYaml ("lib.utils.strings.template" (dict "value" $.values.config "context" $.context)))}}
  {{- end }}
  {{- if not ($config.jmxUrl) }}
config:
  jmxUrl: service:jmx:rmi:///jndi/rmi://127.0.0.1:{{ $.values.targetPort }}/jmxrmi
  {{- end }}


## Container Configuration
containerName: {{ $name }}
command:
  - java
  - -XX:+UnlockExperimentalVMOptions
  - -XX:+UseCGroupMemoryLimitForHeap
  - -XX:MaxRAMFraction=1
  - -XshowSettings:vm
  - -jar
  - jmx_prometheus_httpserver.jar
  - "{{ $.values.port }}"
  - /opt/jmx-config/jmx-prometheus.yml
ports:
  - name: "{{ $name }}"
    containerPort: {{ $.values.port }}
volumeMounts:
  - name: "{{ $name }}-config"
    mountPath: /opt/jmx-config

## Service Confiuration
service:
  portName: metrics
  port: "{{ $.values.port }}"
  targetPort: "{{ $.values.port }}"
  labels: {{ toYaml $.values.labels | nindent 4 }}
    manifests.bedag/component: {{ $name }}
  annotations:
    prometheus.io/port: "{{ $.values.port }}"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/"

## ServiceMonitor Configuration
serviceMonitor:
  endpoints:
    - port: metrics
      {{- toYaml $.values.endpoint | nindent 6 }}
    {{- if $.values.serviceMonitor.endpoints }}
      {{- toYaml $.values.serviceMonitor.endpoints | nindent 4 }}
    {{- end }}
  labels: {{ toYaml $.values.labels | nindent 4 }}
    manifests.bedag/component: {{ $name }}
  selector: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $.context) $.values.serviceMonitor.selector) "context" $.context) | nindent 4 }}
    manifests.bedag/component: {{ $name }}
{{- end }}
