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
{{- define "bedag-lib.manifest.statefulset" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $statefulset := mergeOverwrite (fromYaml (include "bedag-lib.values.statefulset" $)).statefulset (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $statefulset) }}
      {{- with $statefulset }}
kind: StatefulSet
        {{- if .apiVersion }}
apiVersion: {{ .apiVersion }}
        {{- else }}
apiVersion: apps/v1
        {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" $ }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" .labels "context" $context)| nindent 4 }}
        {{- with .namespace }}
  namespace: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) }}
        {{- end }}
        {{- with .annotations }}
  annotations:
          {{- range $anno, $val := . }}
            {{- $anno | nindent 4 }}: {{ $val | quote }}
          {{- end }}
        {{- end }}
spec:
  podManagementPolicy: {{ default "OrderedReady" .podManagementPolicy }}
  updateStrategy:
        {{- $updateStrategy := (default "RollingUpdate" .updateStrategy) }}
    type: {{ $updateStrategy | quote }}
        {{- if (eq "OnDelete" $updateStrategy) }}
    rollingUpdate: null
        {{- else if .rollingUpdatePartition }}
    rollingUpdate:
      partition: {{ .rollingUpdatePartition }}
        {{- end }}
  replicas: {{ default "1" .replicaCount }}
  selector:
        {{- if .selector }}
          {{- include "lib.utils.strings.template" (dict "value" .selector "context" $context) | nindent 4 }}
        {{- else }}
    matchLabels: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $context) .selectorLabels) "context" $context) | nindent 6 }}
        {{- end }}
  serviceName: {{ default (include "bedag-lib.utils.common.fullname" $) .serviceName }}
        {{- with .statefulsetExtras }}
          {{- toYaml .statefulsetExtras | nindent 2 }}
        {{- end }}
  template: {{- include "bedag-lib.template.pod" (set $ "pod" $statefulset) | nindent 4 }}
        {{- with .volumeClaimTemplates }}
  volumeClaimTemplates: {{- toYaml . | nindent 4 }}
        {{- end }}
      {{- end }}  
    {{- end }}  
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end -}}
