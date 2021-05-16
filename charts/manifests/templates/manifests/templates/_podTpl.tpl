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
{{- define "bedag-lib.template.pod" -}}
  {{- $values := mergeOverwrite (fromYaml (include "bedag-lib.values.template.pod" .)) .pod -}}
  {{- if and $values (include "bedag-lib.utils.intern.noYamlError" $values) .context (include "bedag-lib.utils.intern.noYamlError" .context) -}}
    {{- $context := .context -}}
metadata:
  labels: {{- include "lib.utils.common.labels" (dict "labels" $values.podLabels "versionUnspecific" "true" "context" $context)| nindent 4 }}
    {{- if or $values.podAnnotations $values.forceRedeploy }}
  annotations:
      {{- if $values.forceRedeploy }}
    timestamp: {{ now.Unix | quote }}
      {{- end }}
      {{- if or $values.podAnnotations }}
        {{- range $anno, $val := $values.podAnnotations }}
          {{- $anno | nindent 4 }}: {{ include "lib.utils.strings.template" (dict "value" $val "context" $context) }}
        {{- end }}
      {{- end }}
    {{- end }}
spec:
    {{- if $values.podFields }}
      {{- include "lib.utils.strings.template" (dict "value" $values.podFields "context" $context) | nindent 2 }}
    {{- end }}
    {{- with $values.restartPolicy }}
  restartPolicy: {{ . }}
    {{- end }}
    {{- $pullSecrets := include "lib.utils.globals.imagePullSecrets" (dict "pullSecrets" $values.imagePullSecrets "context" $context) }}
    {{- if $pullSecrets }}
  imagePullSecrets: {{- toYaml $pullSecrets | nindent 4 }}
    {{- end }}
    {{- with $values.affinity }}
  affinity: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
    {{- end }}
    {{- with $values.nodeSelector }}
  nodeSelector: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
    {{- end }}
    {{- with $values.tolerations }}
  tolerations: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
    {{- end }}
    {{- with $values.priorityClassName }}
  priorityClassName: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
    {{- end }}
    {{- with $values.podSecurityContext }}
  securityContext: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
    {{- end }}
    {{- if $values.serviceAccount }}
      {{- $_ := set . "sa" $values.serviceAccount }}
  serviceAccountName: {{ include "bedag-lib.utils.common.serviceAccountName" . }}
    {{- end }}
    {{- with $values.initContainers }}
  initContainers: {{- toYaml $values.initContainers | nindent 4 }}
    {{- end }}
  containers:
    - {{- include "bedag-lib.template.container" (set . "container" $values) | nindent 6 }}
    {{- with $values.sidecars }}
      {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
    {{- end }}
    {{- with $values.volumes }}
  volumes: {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.pod' and '.context' as arguments" }}
  {{- end }}
{{- end -}}
