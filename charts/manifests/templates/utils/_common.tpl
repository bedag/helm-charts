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
