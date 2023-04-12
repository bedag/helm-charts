{{/* Go Regex IP */}}
{{- define "pkg.utils.regex.ip" -}}
(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}
{{- end -}}

{{/* Go Regex Port */}}
{{- define "pkg.utils.regex.port" -}}
^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$
{{- end -}}

{{/* Go Regex to extract host from url (UNTESTED) */}}
{{- define "pkg.utils.regex.host" -}}
^(?:(?:https?|ftp):\/\/)?(?:[^@\/\n]+@)?([^:\/?\n]+)
{{- end -}}

{{/* Go Regex to extract IP */}}
{{- define "pkg.utils.envvar" -}}
{{- printf "%s" ($ | replace "-" "_") -}}
{{- end -}}

{{/* Return Timezone */}}
{{- define "pkg.utils.tz" -}}
  {{- with $.Values.utils.timezone }}
    {{- printf "%s" . -}}
  {{- end }}
{{- end -}}

{{/* Fail with some spaces */}}
{{- define "pkg.utils.fail" -}}
  {{- fail (printf "\n\n%s" $) -}}
{{- end -}}

{{- define "pkg.utils.unmarshalingError" -}}
  {{- if $.Error -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/* Required for temporary Helm directory */}}
{{- define "pkg.utils.xdg-env" -}}
- name: "XDG_DATA_HOME"
  value: "/cache"
- name: "XDG_CONFIG_HOME"
  value: "/cache"
- name: "XDG_CACHE_HOME"
  value: "/cache"
{{- end -}}

{{/* Template map/strings to YAML */}}
{{- define "pkg.utils.template" -}}
  {{- if $.ctx }}
    {{- if typeIs "string" $.tpl }}
      {{- tpl  $.tpl $.ctx  | replace "+|" "\n" }}
    {{- else }}
      {{- tpl ($.tpl | toYaml) $.ctx | replace "+|" "\n" }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/* Render Addition Environment Variables */}}
{{- define "pkg.utils.envs" -}}
  {{- range $key, $value := $.envs }}
- name: {{ $key }}
  value: {{ include "pkg.utils.template" (dict "tpl" $value "ctx" $.ctx) }} 
  {{- end }}
{{- end -}}

{{/* Render Addition Args */}}
{{- define "pkg.utils.args" -}}
  {{- range $key, $value := $.args }}
    {{- if not (kindIs "invalid" $value) }}
- --{{ $key | mustRegexFind "^[^_]+" }}={{ include "pkg.utils.template" (dict "tpl" $value "ctx" $.ctx) }}
    {{- else }}
- --{{ $key | mustRegexFind "^[^_]+" }}
    {{- end }}
  {{- end }}
{{- end -}}


{{- define "pkg.utils.kubeVersion" -}}
{{- default .Capabilities.KubeVersion.Version .Values.utils.kubeVersion -}}
{{- end -}}