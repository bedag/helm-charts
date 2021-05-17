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
{{- define "bedag-lib.manifest.cronjob" -}}
  {{- if .context }}
    {{- $context := .context -}}
    {{- $cronjob := mergeOverwrite (fromYaml (include "bedag-lib.values.cronjob" $)).cronjob (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $cronjob) -}}
      {{- with $cronjob -}}
        {{- if .enabled }}
kind: CronJob
          {{- if .apiVersion }}
apiVersion: {{ .apiVersion }}
          {{- else }}
apiVersion: batch/v1beta1
          {{- end }}
metadata:
  name:  {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" .labels "context" $context)| nindent 4 }}
          {{- with .namespace }}   
  namespace: {{- include "lib.utils.strings.template" (dict "value" . "context" $context) }}
          {{- end }}
          {{- with .annotations }}
  annotations:
            {{- range $anno, $val := . }}
              {{- $anno | nindent 4 }}: {{ $val | quote }}
            {{- end }}
          {{- end }}
spec:
          {{- with .cronJobFields }}
            {{- toYaml . | nindent 2 }}
          {{- end }}
  concurrencyPolicy: {{ .concurrencyPolicy }}
  failedJobsHistoryLimit: {{ .failedJobsHistoryLimit }}
  schedule: {{ .schedule | quote }}
  startingDeadlineSeconds: {{ .startingDeadlineSeconds }}
  successfulJobsHistoryLimit: {{ .successfulJobsHistoryLimit }}
  suspend: {{ .suspend }}
  jobTemplate: {{- include "bedag-lib.template.job" (set $ "job" .) | nindent 4 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
