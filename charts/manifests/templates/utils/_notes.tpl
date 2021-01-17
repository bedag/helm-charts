/*

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

*/
{{- define "bedag-lib.utils.notes.public" -}}
  {{- $context := (default $ .context) -}}
  {{- if or .ingress .service}}
    {{- $path := (default "" .path) -}}
    {{- if .ingress }}
      {{- if .ingress.enabled }}
        {{- range $host := .ingress.hosts }}
          {{- range .paths }}
             {{- $l_path := dict }}
             {{- if (kindIs "string" .) }}
               {{ $_ := set $l_path "path" . }}
             {{- else }}
               {{- $l_path = . }}
             {{- end }}
http{{ if $.ingress.tls }}s{{ end }}://{{ $host.host }}{{ if $l_path.path }}{{ $l_path.path | trimSuffix "/"}}{{ else }}{{ .| trimSuffix "/"}}{{ end }}{{ $path }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- else if .service }}
      {{- if .service.enabled }}
        {{- if contains "NodePort" .service.type }}
export NODE_PORT=$(kubectl get --namespace {{ $context.Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "bedag-lib.utils.common.fullname" $context }})
export NODE_IP=$(kubectl get nodes --namespace {{ $context.Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT{{ $path }}
        {{- else if contains "LoadBalancer" .service.type }}
export SERVICE_IP=$(kubectl get svc --namespace {{ $context.Release.Namespace }} {{ include "bedag-lib.utils.common.fullname" . }} --template "{{"{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}"}}")
echo http://$SERVICE_IP:{{ .service.port }}{{ $path }}
        {{- else if contains "ClusterIP" .service.type }}
export POD_NAME=$(kubectl get pods --namespace {{ $context.Release.Namespace }} -l "app.kubernetes.io/name={{ include "lib.utils.common.name" $context }},app.kubernetes.io/instance={{ $context.Release.Name }}" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:8080{{ $path }}"
kubectl --namespace {{ $context.Release.Namespace }} port-forward $POD_NAME 8080:80
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
