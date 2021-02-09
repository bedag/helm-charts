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
    {{- if (include "bedag-lib.utils.intern.noYamlError" $cronjob) }}
      {{- if $cronjob.enabled }}
kind: CronJob
        {{- if $cronjob.apiVersion }}
apiVersion: {{ $cronjob.apiVersion }}
        {{- else }}
apiVersion: batch/v1beta1
        {{- end }}
metadata:
  name:  {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $cronjob.labels "context" $context)| nindent 4 }}
        {{- if $cronjob.annotations }}
  annotations:
          {{- range $anno, $val := $cronjob.annotations }}
            {{- $anno | nindent 4 }}: {{ $val | quote }}
          {{- end }}
        {{- end }}
spec:
  concurrencyPolicy: {{ $cronjob.concurrencyPolicy }}
  failedJobsHistoryLimit: {{ $cronjob.failedJobsHistoryLimit }}
  schedule: {{ $cronjob.schedule | quote }}
  startingDeadlineSeconds: {{ $cronjob.startingDeadlineSeconds }}
  successfulJobsHistoryLimit: {{ $cronjob.successfulJobsHistoryLimit }}
  suspend: {{ $cronjob.suspend }}
  jobTemplate: {{- include "bedag-lib.template.job" (set . "job" $cronjob) | nindent 4 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
