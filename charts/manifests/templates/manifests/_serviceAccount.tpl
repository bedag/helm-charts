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
{{- define "bedag-lib.manifest.serviceaccount" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $serviceAccount := mergeOverwrite (fromYaml (include "bedag-lib.values.serviceaccount" $)).serviceAccount (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $serviceAccount) }}
      {{- with $serviceAccount -}}
        {{- if .create -}}
kind: ServiceAccount
          {{- if .apiVersion }}
apiVersion: {{ .apiVersion }}
          {{- else }}
apiVersion: v1
          {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.serviceAccountName" (dict "sa" . "context" $context) }}
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
          {{- with .automountServiceAccountToken }}
automountServiceAccountToken: {{ . }}
          {{- end }}
          {{- with .secrets }}
secrets: {{ toYaml . | nindent 2 }}
          {{- end }}
          {{- if or (and .imagePullSecrets (kindIs "slice" .imagePullSecrets)) .globalPullSecrets }}
            {{- if .globalPullSecrets }}
imagePullSecrets: {{- include "lib.utils.globals.imagePullSecrets" (dict "pullSecrets" .imagePullSecrets "context" $context) | nindent 2 }}
            {{- else }}
imagePullSecrets: {{ toYaml .imagePullSecrets | nindent 2 }}
            {{- end }}
          {{- end }}  
        {{- end }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end -}}
