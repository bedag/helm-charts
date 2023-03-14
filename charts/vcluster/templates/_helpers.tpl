{{/*
  Component
*/}}
{{- define "vcluster.component" -}}
vcluster
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "vcluster.name" -}}
{{- include "vcluster.component" $ -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vcluster.fullname" -}}
{{- $name := include "vcluster.component" $ }}
{{- printf "%s-%s" (include "pkg.cluster.name" $) $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Base labels (Base)
*/}}
{{- define "vcluster.labels" -}}
{{ include "pkg.common.labels" $ }}
{{ include "vcluster.selectorLabels" $ }}
{{- end }}

{{/*
  Selector labels (Base)
*/}}
{{- define "vcluster.selectorLabels" -}}
{{ include "pkg.common.labels.part-of" $ }}: {{ include "vcluster.component" $ }}
{{ include "pkg.common.labels.component" $ }}: {{ include "vcluster.component" $ }}
{{ include "pkg.common.selectors" $ }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vcluster.serviceAccountName" -}}
{{- $manifest := $.Values.jobs -}}
{{- if $manifest.serviceAccount.create }}
{{- default (include "vcluster.fullname" $) $manifest.serviceAccount.name }}
{{- else }}
{{- default "default" $manifest.serviceAccount.name }}
{{- end }}
{{- end }}
