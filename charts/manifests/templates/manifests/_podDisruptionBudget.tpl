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
{{- define "bedag-lib.manifest.poddisruptionbudget" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $pdb := mergeOverwrite (fromYaml (include "bedag-lib.values.poddisruptionbudget" $)).pdb (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $pdb) }}
      {{- if $pdb.enabled -}}
kind: PodDisruptionBudget
        {{- if $pdb.apiVersion }}
apiVersion: {{ $pdb.apiVersion }}
        {{- else }}
apiVersion: policy/v1beta1
        {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $pdb.labels "context" $context)| nindent 4 }}
spec:
        {{- if or $pdb.minAvailable $pdb.maxUnavailable}}
          {{- if $pdb.minAvailable }}
  minAvailable: {{ $pdb.minAvailable }}
          {{- end }}
          {{- if $pdb.maxUnavailable }}
  maxUnavailable: {{ $pdb.maxUnavailable }}
          {{- end }}
        {{- else }}
  minAvailable: 1
        {{- end }}
  selector:
    matchLabels: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $context) $pdb.selectorLabels) "context" $context) | nindent 6 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
