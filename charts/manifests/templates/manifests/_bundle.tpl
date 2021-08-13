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
{{- define "bedag-lib.manifest.bundle" -}}
  {{- $manifestPath := "bedag-lib.manifest." -}}
  {{- $bundle := (default dict .bundle) }}
  {{- $i_context := set (default . .context) "Bundle" $bundle }}
  {{- if not $bundle }}
    {{- $bundle = (fromYaml (include "chart.bundle" $i_context)) }}
  {{- end -}}
  {{- if (include "bedag-lib.utils.intern.noYamlError" .) }}
    {{- if and (kindIs "map" $i_context) (include "bedag-lib.utils.intern.noYamlError" $i_context) (kindIs "map" $bundle) (include "bedag-lib.utils.intern.noYamlError" $bundle) -}}
      {{- $context := mergeOverwrite $i_context (dict "Values" (default dict $bundle.common)) -}}
      {{- if (include "bedag-lib.utils.intern.noYamlError" $context) }}
        {{- if $bundle.resources -}}
          {{- range $bundle.resources -}}
            {{- $type := required "Missing required field '.type' for resource in bundle" .type | lower }}
            {{- $manifest := (cat $manifestPath $type | nospace) -}}
            {{- if and (eq $type "raw") .manifest }}
---{{- include "lib.utils.strings.template" (dict "value" .manifest "context" $context) | nindent 0 }}
            {{- else }}
              {{- $parameters := (dict "name" (default $bundle.name .name) "fullname" (default $bundle.fullname .fullname) "prefix" (default $bundle.prefix .prefix) "values" (default dict .values) "overwrites" (default dict .overwrites) "context" $context) }}
              {{- $resource := include $manifest $parameters }}
              {{- if $resource }}
---{{- $resource | nindent 0 }}
                {{- include "bedag-lib.template.bundleExtras" $parameters | nindent 0 -}}
              {{- end -}}
            {{- end -}}
          {{- end -}}
        {{- else }}
          {{- fail "Missing Keys or Wrong YAML structure!" }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end -}}
{{- end -}}
