/*

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

*/
{{/*
  Sprig Template - KeyList
*/}}
{{- define "bedag-lib.utils.environment.keyList" -}}
  {{- if .context }}
    {{- $context := .context }}
    {{- include "lib.utils.extras.environment" $context | indent 0 }}
    {{- if .environment }}
      {{- $filteredList := list -}}
      {{- range .environment }}
        {{- if .secret }}
          {{- if $.allowSecrets }}
- name: {{ required "Field .name is required for environment item!" .name | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ include "bedag-lib.utils.common.fullname" $context }}-env
      key: {{ .name | quote }}
          {{- end }}
        {{- else }}
            {{- $filteredList = append $filteredList . -}}
        {{- end }}
      {{- end }}
      {{- if $filteredList }}
        {{- include "lib.utils.strings.template" (dict "value" $filteredList "context" $context) | nindent 0 }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as argument" }}
  {{- end }}
{{- end -}}


{{/*
  Sprig Template - HasSecrets
*/}}
{{- define "bedag-lib.utils.environment.hasSecrets" -}}
  {{- if kindIs "slice" . }}
    {{- range . }}
      {{- if .secret }}
        {{- true -}}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- fail "Template context is not type 'slice'" }}
  {{- end }}
{{- end -}}
