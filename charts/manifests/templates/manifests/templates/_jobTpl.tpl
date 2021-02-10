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
{{- define "bedag-lib.template.job" -}}
  {{- $values := mergeOverwrite (fromYaml (include "bedag-lib.values.template.job" .)) .job -}}
  {{- if and $values (include "bedag-lib.utils.intern.noYamlError" $values) .context (include "bedag-lib.utils.intern.noYamlError" .context) -}}
    {{- $context := .context }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $values.labels "context" $context)| nindent 4 }}
    {{- if $values.annotations }}
  annotations:
      {{- range $anno, $val := $values.annotations }}
        {{- $anno | nindent 4 }}: {{ $val | quote }}
      {{- end }}
    {{- end }}
spec:
    {{- if $values.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ $values.activeDeadlineSeconds }}
    {{- end }}
    {{- if $values.backoffLimit }}
  backoffLimit: {{ $values.backoffLimit }}
    {{- end }}
    {{- if $values.completions }}
  completions: {{ $values.completions }}
    {{- end }}
    {{- if $values.manualSelector }}
  manualSelector: true
    {{- end }}
    {{- if $values.parallelism }}
  parallelism: {{ $values.parallelism }}
    {{- end }}
    {{- if $values.ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ $values.ttlSecondsAfterFinished }}
    {{- end }}
    {{- if $values.selector }}
  selector: {{ toYaml $values.selector | nindent 4 }}
    {{- end }}
    {{- $_ := set . "pod" $values }}
  template: {{- include "bedag-lib.template.pod" (set . "pod" $values) | nindent 4 }}
  {{- else }}
    {{- fail "Template requires '.pod' and '.context' as arguments" }}
  {{- end }}
{{- end }}
