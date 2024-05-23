{{- define "isString" -}}
{{- if (kindIs "string" .) }}{{- . }}{{- else }}{{- toYaml . }}{{- end }}
{{- end -}}