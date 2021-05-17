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
{{- define "bedag-lib.manifest.persistentvolumeclaim" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $pvc := mergeOverwrite (fromYaml (include "bedag-lib.values.persistentvolumeclaim" $)).pvc (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $pvc) -}}
      {{- with $pvc -}}
        {{- if .enabled -}}
kind: PersistentVolumeClaim
          {{- if .apiVersion }}
apiVersion: {{ .apiVersion }}
          {{- else }}
apiVersion: v1
          {{- end }}
          {{- include "bedag-lib.template.persistentvolumeclaim" (set $ "pvc" $pvc) | nindent 0 }}
        {{- end }}  
      {{- end }}
    {{- else }}
      {{- fail "Template requires '.context' as arguments" }}
    {{- end }}
  {{- end }}
{{- end }}
