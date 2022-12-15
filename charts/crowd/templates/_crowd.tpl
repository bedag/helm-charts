{{/*
 Crowd Component Label
*/}}
{{- define "crowd.component" -}}
app.kubernetes.io/component: "crowd"
{{- end -}}

{{/*
Crowd Mode Label
*/}}
{{- define "crowd.mode" -}}
  {{- if $.Values.crowd.cluster.enabled -}}
atlassian.com/mode: "clustered"
  {{- else -}}
atlassian.com/mode: "standalone"
  {{- end -}}
{{- end -}}

{{/*
Crowd Labels
*/}}
{{- define "crowd.Labels" -}}
atlassian.com/component: "crowd"
app.kubernetes.io/part-of: "crowd"
{{ include "crowd.mode" $ | indent 0 }}
{{- end -}}

{{/*
Crowd Home
*/}}
{{- define "crowd.home" -}}
{{ .Values.crowd.home | trimSuffix "/" }}
{{- end -}}

{{/*
  Crowd JVM Arguments
*/}}
{{- define "crowd.jvm_args" -}}
{{ if $.Values.crowd.jvm_args }}{{- include "lib.utils.strings.stringify" (dict "list" $.Values.crowd.jvm_args "delimiter" "  " "context" $) }}{{- end }} {{ include "bedag-lib.utils.helpers.javaProxies" (dict "proxy" $.Values.proxy "context" $) }}
{{- end -}}

{{/*
  Crowd Catalina Options
*/}}
{{- define "crowd.catalina_opts" -}}
{{ if $.Values.crowd.cluster.enabled }}{{ if $.Values.crowd.cluster.nodeName }}-Dcluster.node.name="$POD_NAME"{{ end }}{{ end }}{{ if $.Values.crowd.catalina_opts }}{{- include "lib.utils.strings.stringify" (dict "list" $.Values.crowd.catalina_opts "delimiter" "  " "context" $) }}{{- end }}
{{- end -}}


{{/*
  Crowd Volumepermission Preset
*/}}
{{- define "crowd.volumePermission.values" -}}
  {{- if $.Values.volumePermissions.enabled }}
enabled: true
    {{- if or (and $.Values.crowd.persistence (or (and $.Values.crowd.clustered $.Values.shared.enabled) $.Values.home.enabled)) $.Values.volumePermissions.volumeMounts }}
volumeMounts:
      {{- if $.Values.volumePermissions.volumeMounts }}
        {{- toYaml $.Values.volumePermissions.volumeMounts | nindent 2 }}
      {{- end }}
      {{- if $.Values.crowd.persistence }}
        {{- if and $.Values.crowd.clustered $.Values.shared.enabled }}
  - name: shared
    mountPath: /crowd/share
        {{- end }}
        {{- if $.Values.home.enabled }}
  - name: home
    mountPath: /crowd/data
        {{- end }}
      {{- end }}
    {{- end }}
  {{- else }}
enabled: false
  {{- end }}
{{- end -}}


{{/*
  Crowd Environment Variables based on Configuration
*/}}
{{- define "crowd.configuration" -}}
- name: "JVM_MINIMUM_MEMORY"
  value: {{ $.Values.crowd.memory.min }}
- name: "JVM_MAXIMUM_MEMORY"
  value: {{ $.Values.crowd.memory.max }}
- name: "CROWD_HOME"
  value: {{ template "crowd.home" . }}
- name: "ATL_TOMCAT_PORT"
  value: {{ $.Values.crowd.port | quote }}
{{- end -}}
