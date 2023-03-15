{{/* Install In-Cluster */}}
{{- define "pkg.dev.incluster" -}}
  {{- if $.Values.utils.currentcluster -}}
    {{- true -}}
  {{- end -}}
{{- end -}}
