
{{/*
  Name for Cluster
*/}}
{{- define "eck.name" -}}
{{ $.Values.global.cluster.name }}
{{- end -}}

{{/*
  Labels for all resources
*/}}
{{- define "eck.labels" -}}
{{- toYaml (merge (fromYaml (include "lib.utils.common.commonLabels" $)) (default dict $.Values.global.labels)) }}
{{- end -}}

{{/*
  ECK CLuster Version
*/}}
{{- define "eck.version" -}}
{{- default $.Release.appVersion $.Values.global.cluster.version -}}
{{- end -}}


{{- define "eck.context" -}}
  {{ $p := $.Values }}
{{- toYaml (merge $.Values.global.common $p) }}
{{- end -}}
