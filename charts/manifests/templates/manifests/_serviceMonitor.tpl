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
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $serviceMonitor.labels "context" $context)| nindent 4 }}
        {{- if $serviceMonitor.namespace }}
  namespace: {{- include "lib.utils.strings.template" (dict "value" $serviceMonitor.namespace "context" $context) }}
        {{- end }}
        {{- with $serviceMonitor.annotations }}
  annotations:
          {{- range $anno, $val := . }}
            {{- $anno | nindent 4 }}: {{ $val | quote }}
          {{- end }}
        {{- end }}
spec:
        {{- if $serviceMonitor.additionalFields }}
          {{- toYaml $serviceMonitor.additionalFields | nindent 2 }}
        {{- end }}
  selector:
    matchLabels: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $context) $serviceMonitor.selector) "context" $context) | nindent 6 }}
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
  {{- end }}
{{- end }}
