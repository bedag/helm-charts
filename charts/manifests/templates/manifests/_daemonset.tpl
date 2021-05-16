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
{{- define "bedag-lib.manifest.daemonset" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $daemonset := mergeOverwrite (fromYaml (include "bedag-lib.values.daemonset" $)).daemonset (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $daemonset) }}
kind: DaemonSet
      {{- if $daemonset.apiVersion }}
apiVersion: {{ $daemonset.apiVersion }}
      {{- else }}
apiVersion: apps/v1
      {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $daemonset.labels "context" $context)| nindent 4 }}
      {{- with $daemonset.annotations }}
  annotations:
        {{- range $anno, $val := . }}
          {{- $anno | nindent 4 }}: {{ $val | quote }}
        {{- end }}
      {{- end }}
spec:
  minReadySeconds: {{ default 0 $daemonset.minReadySeconds }}
  revisionHistoryLimit: {{ default 10 $daemonset.revisionHistoryLimit }}
  selector:
    matchLabels: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $context) $daemonset.selectorLabels) "context" $context) | nindent 6 }}
  template: {{- include "bedag-lib.template.pod" (set . "pod" $daemonset) | nindent 4 }}
  updateStrategy:
      {{- $updateStrategy := (default "RollingUpdate" $daemonset.updateStrategy) }}
    type: {{ $updateStrategy | quote }}
      {{- if (eq "OnDelete" $updateStrategy) }}
    rollingUpdate: null
      {{- else if $daemonset.rollingUpdatemaxUnavailable }}
    rollingUpdate:
      maxUnavailable: {{ $daemonset.rollingUpdatemaxUnavailable }}
      {{- end }}
    {{- end }}
  {{- end -}}
{{- end -}}
