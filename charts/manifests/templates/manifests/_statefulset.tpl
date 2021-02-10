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
{{- define "bedag-lib.manifest.statefulset" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $statefulset := mergeOverwrite (fromYaml (include "bedag-lib.values.statefulset" $)).statefulset (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $statefulset) }}
kind: StatefulSet
      {{- if $statefulset.apiVersion }}
apiVersion: {{ $statefulset.apiVersion }}
      {{- else }}
apiVersion: apps/v1
      {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $statefulset.labels "context" $context)| nindent 4 }}
spec:
  podManagementPolicy: {{ default "OrderedReady" $statefulset.podManagementPolicy }}
  updateStrategy:
      {{- $updateStrategy := (default "RollingUpdate" $statefulset.updateStrategy) }}
    type: {{ $updateStrategy | quote }}
      {{- if (eq "OnDelete" $updateStrategy) }}
    rollingUpdate: null
      {{- else if $statefulset.rollingUpdatePartition }}
    rollingUpdate:
      partition: {{ $statefulset.rollingUpdatePartition }}
      {{- end }}
  replicas: {{ default "1" $statefulset.replicaCount }}
  selector:
    matchLabels: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $context) $statefulset.selectorLabels) "context" $context) | nindent 6 }}
  serviceName: {{ default (include "bedag-lib.utils.common.fullname" .) $statefulset.serviceName }}
      {{- if $statefulset.statefulsetExtras }}
        {{- toYaml $statefulset.statefulsetExtras | nindent 2 }}
      {{- end }}
  template: {{- include "bedag-lib.template.pod" (set . "pod" $statefulset) | nindent 4 }}
      {{- if and $statefulset.volumeClaimTemplates (kindIs "slice" $statefulset.volumeClaimTemplates) }}
  volumeClaimTemplates: {{- toYaml $statefulset.volumeClaimTemplates | nindent 4 }}
      {{- end }}
    {{- end }}  
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end -}}
