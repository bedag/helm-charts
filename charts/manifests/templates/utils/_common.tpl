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
  Sprig Template - Fullname Template Wrapper. Considers the Bundlename as prefix, if defined.
*/}}
{{- define "bedag-lib.utils.common.fullname" -}}
  {{- $c := . -}}
  {{- $_ := set $c "context" (default . .context) }}
  {{- $_ := set $c "prefix" (default $c.context.bundlename .bundlename) }}
  {{- include "lib.utils.common.fullname" $c }}
{{- end }}


{{/*
  Sprig Template - ServiceAccountName
*/}}
{{- define "bedag-lib.utils.common.serviceAccountName" -}}
  {{- if .context }}
    {{- if .sa }}
      {{- if or .sa.enabled .sa.create }}
        {{- if .sa.enabled }}
          {{- if .sa.create -}}
            {{- printf "%s" (default (include "bedag-lib.utils.common.fullname" .) .sa.name) }}
          {{- else -}}
            {{- printf "%s" (default "default" .sa.name) }}
          {{- end -}}
        {{- end }}
      {{- else }}
        {{- printf "%s" "default" }}
      {{- end }}
    {{- else }}
      {{- printf "%s" "default" }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end -}}


{{/*
  Sprig Template - SelectorLabels Wrapper. Adds Bundlename to selectorLabels, if defined.
*/}}
{{- define "bedag-lib.utils.common.selectorLabels" -}}
{{- $c := . -}}
{{- include "lib.utils.common.selectorLabels" $c }}
{{- if .bundlename }}
app.kubernetes.io/bundle:  {{ .bundlename }}
{{- end }}
{{- end -}}


{{/*
  Sprig Template - DefaultLabels Wrapper. Adds Bundlename to DefaultLabels, if defined.
*/}}
{{- define "bedag-lib.utils.common.defaultLabels" -}}
{{- include "bedag-lib.utils.common.selectorLabels" . }}
{{- if and .Chart.AppVersion (not .versionunspecific) }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}


{{/*
  Sprig Template - OverwriteLabels Wrapper. Adds Bundlename to OverwriteLabels, if defined.
*/}}
{{- define "bedag-lib.utils.common.overwriteLabels" -}}
  {{- if and $.Values.overwriteLabels (kindIs "map" $.Values.overwriteLabels) }}
    {{- include "lib.utils.strings.template" (dict "value" $.Values.overwriteLabels "context" $) | nindent 0 }}
  {{- else }}
    {{- include "bedag-lib.utils.common.defaultLabels" . | indent 0}}
  {{- end }}
{{- end -}}


{{/*
  Sprig Template - CommonLabels Wrapper. Adds Bundlename to CommonLabels, if defined.
*/}}
{{- define "bedag-lib.utils.common.commonLabels" -}}
  {{- include "bedag-lib.utils.common.overwriteLabels" . | indent 0 }}
  {{- if and $.Values.commonLabels (kindIs "map" $.Values.commonLabels) }}
    {{- include "lib.utils.strings.template" (dict "value" $.Values.commonLabels "context" $) | nindent 0 }}
  {{- end }}
{{- end -}}


{{/*
  Sprig Template - Labels Wrapper. Adds Bundlename to Labels, if defined.
*/}}
{{- define "bedag-lib.utils.common.labels" -}}
  {{- $_ := set (default . .context) "versionunspecific" (default false .versionUnspecific ) -}}
  {{- toYaml (mergeOverwrite (fromYaml (include "bedag-lib.utils.common.commonLabels" (default . .context))) (default dict .labels)) | indent 0 }}
  {{- $_ := unset (default . .context) "versionunspecific" }}
{{- end -}}

