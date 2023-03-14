{{/*
Component enabled
*/}}
{{- define "autoscaler.enabled" -}}
{{- $component := $.Values.autoscaler -}}
  {{- if $component.enabled -}}
    {{- true -}}
  {{- end -}}
{{- end }}

{{/*
  Component
*/}}
{{- define "autoscaler.component" -}}
autoscaler
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "autoscaler.name" -}}
{{- include "autoscaler.component" $ -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "autoscaler.fullname" -}}
{{- $name := include "autoscaler.component" $ }}
{{- printf "%s-%s" (include "pkg.cluster.name" $) $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Base labels (Base)
*/}}
{{- define "autoscaler.labels" -}}
{{ include "pkg.common.labels" $ }}
{{ include "autoscaler.selectorLabels" $ }}
{{- end }}

{{/*
  Selector labels (Base)
*/}}
{{- define "autoscaler.selectorLabels" -}}
{{ include "pkg.common.labels.part-of" $ }}: {{ include "autoscaler.component" $ }}
{{ include "pkg.common.labels.component" $ }}: {{ include "autoscaler.component" $ }}
{{ include "pkg.common.selectors" $ }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "autoscaler.serviceAccountName" -}}
{{- $manifest := $.Values.autoscaler -}}
{{- if $manifest.serviceAccount.create }}
{{- default (include "autoscaler.fullname" $) $manifest.serviceAccount.name }}
{{- else }}
{{- default "default" $manifest.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Expander with Priority Active */}}
{{- define "autoscaler.priorityExpanderEnabled" -}}
{{- $expanders := splitList "," (default "" .Values.autoscaler.args.expander) -}}
  {{- if has "priority" $expanders -}}
    {{- true -}}
  {{- end -}}
{{- end -}}
