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
{{- define "bedag-lib.manifest.horizontalpodautoscaler" -}}
  {{- if .context }}
    {{- $context := .context -}}
    {{- $hpa := mergeOverwrite (fromYaml (include "bedag-lib.values.horizontalpodautoscaler" $)).autoscaling (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $hpa) -}}
      {{- with $hpa -}}
        {{- if and .enabled (or .targetCPUUtilizationPercentage .targetMemoryUtilizationPercentage .metrics) -}}
kind: HorizontalPodAutoscaler
          {{- if .apiVersion -}}
apiVersion: {{ .apiVersion }}
          {{- else }}
apiVersion: autoscaling/v2beta2
          {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" .labels "context" $context) | nindent 4 }}
          {{- with .namespace }}   
  namespace: {{ include "lib.utils.strings.template" (dict "value" . "context" $context) }}
          {{- end }}
          {{- with .annotations }}
  annotations:
            {{- range $anno, $val := . }}
              {{- $anno | nindent 4 }}: {{ $val | quote }}
            {{- end }}
          {{- end }}
spec:
          {{- if .hpaFields }}
            {{- toYaml . | nindent 2 }}
          {{- end }}
          {{- with .behavior }}
  behavior: {{ toYaml . | nindent 4 }}
          {{- end }}
  metrics:
          {{- with .targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: {{ . }}
          {{- end }}
          {{- with .targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: {{ . }}
          {{- end }}
          {{- with .metrics }}
            {{- toYaml . | nindent 4 }}
          {{- end }}
  scaleTargetRef:
          {{- if .scaleTargetRef }}
            {{- toYaml .scaleTargetRef | nindent 4  }}
          {{- else }}
    apiVersion: apps/v1
    kind: Statefulset
    name: {{ include "bedag-lib.utils.common.fullname" $ }}
          {{- end }}
          {{- with .minReplicas }}
  minReplicas: {{ . }}
          {{- end }}
  maxReplicas: {{ .maxReplicas }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end -}}
