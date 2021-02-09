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
{{- define "bedag-lib.manifest.horizontalpodautoscaler.values" -}}
  {{- include "lib.utils.strings.template" (dict "value" (include "bedag-lib.utils.common.mergedValues" (dict "type" "horizontalpodautoscaler" "key" "autoscaler" "root" .)) "context" .context) }}
{{- end }}

{{- define "bedag-lib.manifest.horizontalpodautoscaler" -}}
  {{- if .context }}
    {{- $context := .context -}}
    {{- $hpa := mergeOverwrite (fromYaml (include "bedag-lib.values.horizontalpodautoscaler" $)).autoscaling (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $hpa) }}
      {{- if and $hpa.enabled (or $hpa.targetCPUUtilizationPercentage $hpa.targetMemoryUtilizationPercentage $hpa.metrics) -}}
kind: HorizontalPodAutoscaler
        {{- if $hpa.apiVersion -}}
apiVersion: {{ $hpa.apiVersion }}
        {{- else }}
apiVersion: autoscaling/v2beta2
        {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $hpa.labels "context" $context) | nindent 4 }}
spec:
        {{- if and $hpa.behavior (kindIs "map" $hpa.behavior) }}
  behavior: {{ toYaml $hpa.behavior | nindent 4 }}
        {{- end }}
  metrics:
        {{- if $hpa.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: {{ $hpa.targetCPUUtilizationPercentage }}
        {{- end }}
        {{- if $hpa.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: {{ $hpa.targetMemoryUtilizationPercentage }}
        {{- end }}
        {{- if and $hpa.metrics (kindIs "slice" $hpa.metrics) }}
          {{- toYaml $hpa.metrics | nindent 4}}
        {{- end }}
  scaleTargetRef:
        {{- if $hpa.scaleTargetRef }}
          {{- toYaml $hpa.scaleTargetRef | nindent 4  }}
        {{- else }}
    apiVersion: apps/v1
    kind: Statefulset
    name: {{ include "bedag-lib.utils.common.fullname" . }}
        {{- end }}
        {{- if $hpa.minReplicas }}
  minReplicas: {{ $hpa.minReplicas }}
        {{- end }}
  maxReplicas: {{ $hpa.maxReplicas }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end -}}
