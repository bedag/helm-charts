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
  Sprig Template - File
*/}}
{{- define "bedag-lib.utils.configs.file" -}}
{{- $config := (required "Configuration reference requried" $.config) -}}
{{- default (default "config.yml" .name) $config.name | nindent 0 }}: |- {{- include "bedag-lib.utils.configs.content" $ | nindent 2 }}
{{- end -}}


{{/*
  Sprig Template - Content
*/}}
{{- define "bedag-lib.utils.configs.content" -}}
{{- $c := (required "Context required" $.context) -}}
{{- $config := (required "Configuration reference requried" $.config) -}}
  {{- if $config.content -}}
    {{- $format := (default $.format $config.format) -}}
    {{- if and $format (kindIs "map" $config.content) }}
      {{- range $key, $value := $config.content }}
        {{- $scope := (dict "key" $key "value" $value) -}}
        {{- include "lib.utils.strings.template" (dict "value" $format "context" $c "extraValuesKey" "loop" "extraValues" $scope) | nindent 0 }}
      {{- end }}
    {{- else }}
      {{- include "lib.utils.strings.template" (dict "value" $config.content "context" $c) | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end -}}
