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
{{- define "bedag-lib.manifest.deployment" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $deployment := mergeOverwrite (fromYaml (include "bedag-lib.values.deployment" $)).deployment (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $deployment) }}
kind: Deployment
      {{- if $deployment.apiVersion }}
apiVersion: {{ $deployment.apiVersion }}
      {{- else }}
apiVersion: apps/v1
      {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $deployment.labels "context" $context)| nindent 4 }}
        {{- with $deployment.annotations }}
  annotations:
          {{- range $anno, $val := . }}
            {{- $anno | nindent 4 }}: {{ $val | quote }}
          {{- end }}
        {{- end }}
spec:
      {{- with $deployment.strategy }}
  strategy: {{ toYaml . |  nindent 4 }}
      {{- end }}
  replicas: {{ default "1" $deployment.replicaCount }}
  selector:
    matchLabels: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $context) $deployment.selectorLabels) "context" $context) | nindent 6 }}
      {{- if $deployment.deploymentExtras }}
        {{- toYaml $deployment.deploymentExtras | nindent 2 }}
      {{- end }}
  template: {{- include "bedag-lib.template.pod" (set . "pod" $deployment) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end -}}
