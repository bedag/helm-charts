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
{{- define "bedag-lib.manifest.service" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $svc := mergeOverwrite (fromYaml (include "bedag-lib.values.service" $)).service (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $svc) }}
      {{- with $svc -}}
        {{- if .enabled -}}
kind: Service
          {{- if .apiVersion }}
apiVersion: {{ .apiVersion }}
          {{- else }}
apiVersion: v1
          {{- end }}
metadata:
  name: {{ include "bedag-lib.utils.common.fullname" . }}
  labels: {{- include "lib.utils.common.labels" (dict "labels" .labels "context" $context) | nindent 4 }}
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
        {{- $type := (default "ClusterIP" .type) }}
  type: {{ $type }}
          {{- if eq $type "LoadBalancer" }}
            {{- with .loadBalancerIP }}
  loadBalancerIP: {{ . }}
            {{- end }}
            {{- with .loadBalancerSourceRanges }}
  loadBalancerSourceRanges: {{- toYaml . | nindent 4 }}
            {{- end }}
          {{- end }}
          {{- if and (eq $type "ClusterIP") .clusterIP }}
  clusterIP: {{ .clusterIP }}
          {{- end }}
  ports:
    - name: {{ include "lib.utils.strings.toDns1123" (default "http" .portName) }}
      port: {{ default 80 .port }}
      protocol: {{ default "TCP" .protocol }}
      targetPort: {{ include "lib.utils.strings.toDns1123" (default "http" .targetPort) }}
          {{- if and (or (eq $type "NodePort") (eq $type "LoadBalancer")) (not (empty .nodePort)) }}
      nodePort: {{ .nodePort }}
          {{- else if eq $type "ClusterIP" }}
      nodePort: null
          {{- end }}
          {{- with .extraPorts }}
            {{- toYaml . | nindent 4 }}
          {{- end }}
  selector: {{- include "lib.utils.strings.template" (dict "value" (default (include "lib.utils.common.selectorLabels" $context) .selector) "context" $context) | nindent 4 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end -}}
