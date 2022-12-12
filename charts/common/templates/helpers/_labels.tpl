{{- /*
library.labelize takes a dict or map and generates labels.
Values will be quoted. Keys will not.
Example output:
  first: "Matt"
  last: "Butcher"
*/ -}}
{{- define "library.labelize" -}}
{{- range $k, $v := . }}
{{ $k }}: {{ $v | quote }}
{{- end -}}
{{- end -}}

{{- /*
library.labels.standard prints the standard Helm labels.
The standard labels are frequently used in metadata.

Based on https://helm.sh/docs/chart_best_practices/#standard-labels
*/ -}}
{{- define "library.labels.standard" -}}
app.kubernetes.io/name: {{ template "library.name" . }}
helm.sh/chart: {{ template "library.chartrefshort" . }}
helm.nsm.bedag.ch/chartname: {{ .Chart.Name | quote }}
{{- if (include "library.chartver.prerelease" .) }}
helm.nsm.bedag.ch/chartver-prerelease: {{ template "library.chartver.prerelease" . }}
{{- end }}
{{- if (include "library.chartver.meta" .) }}
helm.nsm.bedag.ch/chartver-meta: {{ template "library.chartver.meta" . }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
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
helm.nsm.bedag.ch/chartname: {{ .Chart.Name | quote }}
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
helm.nsm.bedag.ch/chartname: {{ .Chart.Name | quote }}
{{- end -}}