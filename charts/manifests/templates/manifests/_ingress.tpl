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
{{- define "bedag-lib.manifest.ingress" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $ingress := mergeOverwrite (fromYaml (include "bedag-lib.values.ingress" $)).ingress (default dict .values) (default dict .overwrites) -}}
    {{- if (include "bedag-lib.utils.intern.noYamlError" $ingress) }}
      {{- with $ingress -}}
        {{- if and .enabled .hosts -}}
kind: Ingress
          {{- if .apiVersion -}}
apiVersion: {{ .apiVersion }}
          {{- else -}}
            {{- if semverCompare ">=1.19-0" (include "lib.utils.common.capabilities" $context) }}
apiVersion: networking.k8s.io/v1
            {{- else if semverCompare ">=1.14-0" (include "lib.utils.common.capabilities" $context) }}
apiVersion: networking.k8s.io/v1beta1
            {{- else }}
apiVersion: extensions/v1beta1
            {{- end }}
          {{- end }}
metadata:
  name:  {{ include "bedag-lib.utils.common.fullname" $ }}
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
          {{- with .backend }}
  backend: {{- toYaml . | nindent 4 }}
          {{- end }}
          {{- if semverCompare ">=1.18-0" (include "lib.utils.common.capabilities" $context) -}}
            {{- with .ingressClass }}
  ingressClassName: {{ . }}
            {{- end }}
          {{- end }}
          {{- with .tls }}
  tls: {{- toYaml . | nindent 4 }}
          {{- end }}
  rules:
          {{- range .hosts }}
    - host: {{ required "Field .host required for ingress manifest" .host | quote }}
      http:
        paths:
            {{- range .paths }}
              {{- $p := dict "path" "" "pathType" "" "service" dict "resource" dict }}
              {{- if kindIs "string" . }}
                {{- $_ := set $p "path" . }}
                {{- $_ := set $p "service" (dict "name" (include "bedag-lib.utils.common.fullname" $context) "port" "http") }}
              {{- else }}
                {{- $_ := set $p "path" (default "/" .path) }}
                {{- $_ := set $p "pathType" (default "" .pathType) }}
                {{- if .resource }}
                  {{- $_ := set $p "resource" .resource }}
                {{- else }}
                  {{- $_ := set $p "service" (dict "name" (include "lib.utils.strings.toDns1123" (default (include "bedag-lib.utils.common.fullname" $context) .serviceName)) "port" (default "http" .servicePort)) }}
                {{- end }}
              {{- end }}
          - path: {{ $p.path }}
              {{- if semverCompare ">=1.18-0" (include "lib.utils.common.capabilities" $context) }}
            pathType: {{ default "Prefix" $p.pathType }}
              {{- end }}
            backend:
              {{- if $p.resource }}
              resource: {{- toYaml $p.resource | nindent 16 }}
              {{- else }}
                {{- if semverCompare ">=1.19-0" (include "lib.utils.common.capabilities" $context) }}
              service:
                name: {{ $p.service.name }}
                port:
                  {{- if or (kindIs "int" $p.service.port) (kindIs "float64" $p.service.port) }}
                  number: {{ $p.service.port }}
                  {{- else }}
                  name: {{ include "lib.utils.strings.toDns1123" $p.service.port }}
                  {{- end }}
                {{- else }}
              serviceName: {{ $p.service.name }}
              servicePort: {{ include "lib.utils.strings.toDns1123" $p.service.port }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as argument" }}
  {{- end }}
{{- end -}}
