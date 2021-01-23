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
{{- define "bedag-lib.template.container" -}}
  {{- $values := (mergeOverwrite (fromYaml (include "bedag-lib.values.template.container" .)) .container) -}}
  {{- if and $values (include "bedag-lib.utils.intern.noYamlError" $values) .context (include "bedag-lib.utils.intern.noYamlError" .context) -}}
    {{- $context := .context -}}
name: {{ default $context.Chart.Name $values.containerName }}
image: {{ include "lib.utils.globals.image" (dict "image" $values "context" $context "default" (default $context.Chart.AppVersion .default)) }}
imagePullPolicy: {{ include "lib.utils.globals.imagePullPolicy" (dict "pullPolicy" $values "context" $context) }}
    {{- with $values.securityContext}}
securityContext: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 2 }}
    {{- end }}
    {{- with $values.resources }}
resources: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) | nindent 2 }}
    {{- end }}
    {{- if $values.containerFields }}
      {{- include "lib.utils.strings.template" (dict "value" $values.containerFields "context" $context)  | nindent 0 }}
    {{- end }}
env: {{- include "lib.utils.extras.environment" $context | nindent 2 }}
    {{- if and $values.environment (kindIs "slice" $values.environment) }}
      {{- $filteredList := list -}}
      {{- range $values.environment }}
        {{- if .secret }}
          {{- if $context.Bundle }}
  - name: {{ required "Field .name is required for environment item!" .name | quote }}
    valueFrom:
      secretKeyRef:
        name: {{ include "bedag-lib.utils.common.fullname" $ }}-env
        key: {{ .name | quote }}
          {{- end }}
        {{- else }}
          {{- $filteredList = append $filteredList . -}}
        {{- end }}
      {{- end }}
      {{- if $filteredList }}
        {{- include "lib.utils.strings.template" (dict "value" $filteredList "context" $context) | nindent 2 }}
      {{- end }}
    {{- end }}
    {{- if $values.command }}
command: {{- include "lib.utils.strings.template" (dict "value" $values.command "context" $context) | nindent 2 }}
    {{- end }}
    {{- if $values.args }}
args: {{- include "lib.utils.strings.template" (dict "value" $values.args "context" $context) | nindent 2 }}
    {{- end }}
    {{- with $values.livenessProbe }}
livenessProbe: {{ include "lib.utils.strings.template" (dict "value" $values.livenessProbe "context" $context) | nindent 2 }}
    {{- end }}
    {{- with $values.readinessProbe }}
readinessProbe: {{ include "lib.utils.strings.template" (dict "value" $values.readinessProbe "context" $context)  | nindent 2 }}
    {{- end }}
    {{- if $values.startupProbe }}
startupProbe: {{ include "lib.utils.strings.template" (dict "value" $values.startupProbe "context" $context) | nindent 2 }}
    {{- end }}
    {{- with $values.lifecycle }}
lifecycle: {{ include "lib.utils.strings.template" (dict "value" $values.lifecycle "context" $context) | nindent 2 }}
    {{- end }}
    {{- if and $values.volumeMounts (kindIs "slice" $values.volumeMounts) }}
volumeMounts: {{- include "lib.utils.strings.template" (dict "value" $values.volumeMounts "context" $context) | nindent 2 }}
    {{- end }}
    {{- if and $values.ports (kindIs "slice" $values.ports) }}
ports: {{- include "lib.utils.strings.template" (dict "value" $values.ports "context" $context) | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end -}}
