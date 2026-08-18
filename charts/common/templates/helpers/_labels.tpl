{{- /*
library.mapify is used to generate annotations and labels
where the value can be templated with the given context
*/ -}}
{{- define "library.mapify" -}}
  {{- if $.map -}}
    {{- range $k, $v := $.map -}}
      {{- $k | nindent 0 }}: {{ (tpl $v $.ctx) | quote }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /*
library.annotations renders a metadata "annotations:" block for a given
map of annotations, with each value templated via "library.mapify" (i.e.
"tpl" against the given context). It is meant to be included directly
under a resource's own "metadata:" block, e.g. to set resource-level
annotations such as "helm.sh/hook", as opposed to annotations set on a
Pod template (see e.g. controller.extraAnnotations).
*/ -}}
{{- define "library.annotations" -}}
  {{- if $.map }}
annotations:
  {{- include "library.mapify" (dict "map" $.map "ctx" $.ctx) | nindent 2 }}
  {{- end }}
{{- end -}}

{{- /*
library.labels.standard prints the standard Helm labels.
The standard labels are frequently used in metadata.

Based on https://helm.sh/docs/chart_best_practices/#standard-labels
*/ -}}
{{- define "library.labels.standard" -}}
app.kubernetes.io/name: {{ template "library.name" . }}
helm.sh/chart: {{ template "library.chartrefshort" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ .Values.appVersion | default .Chart.AppVersion | quote }}
{{- end -}}

{{- /*
library.labels.stable prints a set of labels that are stable
within the same release of the chart (contrary to values
that change with each deployment of the release, e.g. versions
and so on).

These labels can be used where labels must not change during the
existence of a resource, for example in selectors.
*/ -}}
{{- define "library.labels.stable" -}}
app.kubernetes.io/name: {{ template "library.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{- /*
library.labels.tillerless prints a minimal set of labels
that can be used when helm renders the resources but
tiller is not used to deploy them.

Version and managed-by labels must be added by whatever
deploy process is used.
*/ -}}
{{- define "library.labels.tillerless" -}}
app.kubernetes.io/name: {{ template "library.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}
