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
{{- define "bedag-lib.manifest.job" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $job := mergeOverwrite (fromYaml (include "bedag-lib.values.job" $)).job (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $job) }}
      {{- with $job -}}
        {{- if .enabled }}
kind: Job
          {{- if .apiVersion }}
apiVersion: {{ .apiVersion }}
          {{- else }}
apiVersion: batch/v1
          {{- end }}
{{- include "bedag-lib.template.job" (set $ "job" .) | nindent 0 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
