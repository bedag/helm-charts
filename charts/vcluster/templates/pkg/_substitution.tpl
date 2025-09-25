{{- define "pkg.substition.variables" -}}

  {{/* Custom Properties */}}
  {{- include "pkg.substition.properties" $ | nindent 0 }}

  {{/* Common Variables */}}
cluster_name: {{ include "pkg.cluster.name" $ }}
  {{- with (include "pkg.images.registry.url" $) }}
registry_host: {{ . }}
  {{- end }}
  {{- with (include "pkg.common.proxy.host" $) }}
proxy: {{ . | quote }}
  {{- end }}
  {{- with (include "pkg.common.proxy.no_proxy" $) }}
no_proxy: {{ . | quote }}
  {{- end }}
  {{- with (include "pkg.utils.tz" $) }}
timezone: {{ . }}
  {{- end }}
  {{- with (include "kubernetes.api.endpointIP" $) }}
kubernetes_api_ip: {{ . | quote }}
  {{- end }}
  {{- with (include "kubernetes.api.endpointPort" $) }}
kubernetes_api_port: {{ . | quote }}
  {{- end }}
{{- end -}}

{{- define "pkg.substition.env" -}}
  {{- $vars := (fromYaml (include "pkg.substition.variables" $)) -}}
  {{- range $key, $value := $vars }}
- name: {{ $key }}
  value: {{ $value | quote }}
  {{- end -}}
{{- end -}}

{{- define "pkg.substition.properties" -}}
  {{/* Cluster Properties */}}
  {{- range $prop, $value := $.Values.cluster.properties }}
    {{- if (kindIs "slice" $value) }}
      {{- range $i, $v := $value }}
{{- include "pkg.utils.envvar" (printf "%s_%s" ($prop | toString) ($i | toString)) | nindent 0 }}: {{ $v | quote }}
      {{- end }}
    {{- else if (kindIs "dict" $value) }}
      {{/* Not Supported */}}}
    {{- else }}
{{- include "pkg.utils.envvar" ($prop | toString) | nindent 0 }}: {{ $value | quote }}
    {{- end }}
  {{- end }}
{{- end -}}
