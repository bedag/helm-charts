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
    {{- with $values }}
metadata:
  labels: {{- include "lib.utils.common.labels" (dict "labels" .podLabels "versionUnspecific" "true" "context" $context)| nindent 4 }}
      {{- with .podNamespace }}   
  namespace: {{ include "lib.utils.strings.template" (dict "value" . "context" $context) }}
      {{- end }}
      {{- if or .podAnnotations .forceRedeploy }}
  annotations:
        {{- if .forceRedeploy }}
    timestamp: {{ now.Unix | quote }}
        {{- end }}
        {{- with .podAnnotations }}
          {{- range $anno, $val := . }}
            {{- $anno | nindent 4 }}: {{ include "lib.utils.strings.template" (dict "value" $val "context" $context) }}
          {{- end }}
        {{- end }}
      {{- end }}
spec:
      {{- with .podFields }}
        {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 2 }}
      {{- end }}
      {{- with .restartPolicy }}
  restartPolicy: {{ . }}
      {{- end }}
      {{- $pullSecrets := include "lib.utils.globals.imagePullSecrets" (dict "pullSecrets" .imagePullSecrets "context" $context) }}
      {{- with $pullSecrets }}
  imagePullSecrets: {{- toYaml . | nindent 4 }}
      {{- end }}
      {{- with .affinity }}
  affinity: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
      {{- end }}
      {{- with .nodeSelector }}
  nodeSelector: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
      {{- end }}
      {{- with .tolerations }}
  tolerations: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
      {{- end }}
      {{- with .priorityClassName }}
  priorityClassName: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
      {{- end }}
      {{- with .podSecurityContext }}
  securityContext: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
      {{- end }}
  serviceAccountName: {{ default (include "bedag-lib.utils.common.serviceAccountName" (set $ "sa" (default dict .serviceAccount))) .serviceAccountName }}
      {{- with .initContainers }}
  initContainers: {{- toYaml . | nindent 4 }}
      {{- end }}
  containers:
    - {{- include "bedag-lib.template.container" (set $ "container" $values) | nindent 6 }}
      {{- with $values.sidecars }}
        {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 4 }}
      {{- end }}
      {{- with $values.volumes }}
  volumes: {{ toYaml . | nindent 4 }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.pod' and '.context' as arguments" }}
  {{- end }}
{{- end -}}
