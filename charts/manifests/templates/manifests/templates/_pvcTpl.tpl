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
{{- define "bedag-lib.template.persistentvolumeclaim" -}}
  {{- $values := mergeOverwrite (fromYaml (include "bedag-lib.values.template.pvc" .)) .pvc -}}
  {{- if and $values (include "bedag-lib.utils.intern.noYamlError" $values) .context (include "bedag-lib.utils.intern.noYamlError" .context) -}}
    {{- $context := .context -}}
    {{- with $values -}}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" $ }}
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
spec:
  accessModes: {{ toJson .accessModes }}
      {{- with .dataSource }}
  dataSource: {{- toYaml . | nindent 4 }}
      {{- end }}
  resources:
    requests:
      storage: {{ default "1Gi" .size | quote }}
  storageClassName: {{ include "lib.utils.globals.storageClass" (dict "persistence" .storageClass "context" $context) }}
      {{- with .selector }}
  selector: {{ toYaml . | nindent 4 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
