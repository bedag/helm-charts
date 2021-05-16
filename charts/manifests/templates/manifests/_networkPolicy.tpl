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
{{- define "bedag-lib.manifest.networkpolicy" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $networkPolicy := mergeOverwrite (fromYaml (include "bedag-lib.values.networkpolicy" $)).networkPolicy (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $networkPolicy) }}
      {{- if $networkPolicy.enabled }}
kind: NetworkPolicy
        {{- if $networkPolicy.apiVersion }}
apiVersion: {{ $networkPolicy.apiVersion }}
        {{- else }}
apiVersion: networking.k8s.io/v1
        {{- end }}
metadata:
  name:  {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" $networkPolicy.labels "context" $context)| nindent 4 }}
      {{- with $networkPolicy.annotations }}
  annotations:
        {{- range $anno, $val := . }}
          {{- $anno | nindent 4 }}: {{ $val | quote }}
        {{- end }}
      {{- end }}
spec:
  podSelector:
    matchLabels: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $context) $networkPolicy.selector) "context" $context) | nindent 6 }}
        {{- if or $networkPolicy.ingress $networkPolicy.egress}}
  policyTypes:
          {{- if and $networkPolicy.ingress (kindIs "slice" $networkPolicy.ingress) }}
    - Ingress
          {{- end }}
          {{- if and $networkPolicy.egress (kindIs "slice" $networkPolicy.egress) }}
    - Egress
          {{- end }}
        {{- end }}
        {{- if and $networkPolicy.ingress (kindIs "slice" $networkPolicy.ingress) }}
  ingress:
          {{- range $networkPolicy.ingress }}
    - from:
            {{- if .ipBlock }}
      - ipBlock: {{- toYaml .ipBlock | nindent 10 }}
            {{- end }}
            {{- if .namespaceSelector }}
      - namespaceSelector:
          matchLabels: {{- include "lib.utils.strings.template" (dict "value" .namespaceSelector "context" $context) | nindent 12 }}
            {{- end }}
            {{- if .podSelector }}
      - podSelector:
          matchLabels: {{- include "lib.utils.strings.template" (dict "value" .podSelector "context" $context) | nindent 12 }}
            {{- end }}
            {{- if .ports }}
      ports: {{- toYaml .ports | nindent 8 }}
            {{- end }}
          {{- end }}
        {{- end }}
        {{- if and $networkPolicy.egress (kindIs "slice" $networkPolicy.egress) }}
  egress:
          {{- range $networkPolicy.egress }}
    - to:
            {{- if .ipBlock }}
      - ipBlock: {{- toYaml .ipBlock | nindent 10 }}
            {{- end }}
            {{- if .ports }}
      ports: {{- toYaml .ports | nindent 8 }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
