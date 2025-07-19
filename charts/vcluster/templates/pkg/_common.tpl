
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pkg.common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common Labels
*/}}
{{- define "pkg.common.labels" -}}
helm.sh/chart: {{ include "pkg.common.chart" . }}
{{- if .Chart.AppVersion }}
{{ include "pkg.common.labels.base" $ }}/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{ include "pkg.common.labels.base" $ }}/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common Selector Labels
*/}}
{{- define "pkg.common.selectors" -}}
{{ include "pkg.common.labels.instance" $ }}: {{ .Release.Name }}
{{ include "pkg.common.labels.name" $ }}: {{ include "pkg.cluster.name" . }}
{{- end -}}

{{- define "pkg.common.labels.name" -}}
{{ include "pkg.common.labels.base" $ }}/name
{{- end -}}

{{- define "pkg.common.labels.component" -}}
{{ include "pkg.common.labels.base" $ }}/component
{{- end -}}

{{- define "pkg.common.labels.instance" -}}
{{ include "pkg.common.labels.base" $ }}/instance
{{- end -}}

{{- define "pkg.common.labels.part-of" -}}
{{ include "pkg.common.labels.base" $ }}/part-of
{{- end -}}

{{- define "pkg.common.labels.base" -}}
  {{- printf "%s" ($.Values.utils.base_label | trimAll "/") -}}
{{- end -}}

{{/*
  Environment
*/}}

{{/* Common Environment */}}
{{- define "pkg.common.env" -}}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
  {{- with (include "pkg.utils.tz" $) }}
- name: TZ
  value: {{ . | quote }}
  {{- end }}
{{- end -}}

{{/* Common Environment (With Proxy Settings) */}}
{{- define "pkg.common.env.w-proxy" -}}
  {{- include "pkg.common.env" $ | nindent 0 }}
  {{- include "pkg.common.proxy.env" $ | nindent 0 }}
{{- end -}}


{{/*
  Proxy
*/}}

{{/* Indicator if Proxy is defined */}}
{{- define "pkg.common.proxy.enabled" -}}
  {{- if .Values.global.proxy.host -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/* Print Proxy Host */}}
{{- define "pkg.common.proxy.host" -}}
  {{- if (include "pkg.common.proxy.enabled" $) -}}
    {{- $proxy := $.Values.global.proxy.host -}}
    {{- printf "%s" $proxy -}}
  {{- end -}}
{{- end -}}

{{/* Print No Proxy */}}
{{- define "pkg.common.proxy.no_proxy" -}}
  {{- $no_proxy := $.Values.global.proxy.no_proxy -}}

  {{/* Inject Additional Stuff */}}
  {{- if (include "pkg.common.proxy.enabled" $) -}}
    {{- $no_proxy = ($no_proxy | trimSuffix ",") -}}

    {{/* Standard Stuff */}}
    {{- $no_proxy = printf "%s,%s,.%s" $no_proxy "localhost,127.0.0.1,.svc,svc." ($.Release.Namespace | trimAll ".") -}}

    {{/* Kubernetes Component */}}
    {{- if (include "kubernetes.enabled" $) -}}
      {{- $kubernetes := $.Values.kubernetes -}}
      {{- with (include "kubernetes.api.service" $) -}}
        {{- $no_proxy = printf "%s,%s" $no_proxy . -}}
      {{- end -}}
      {{- with (include "kubernetes.api.endpointIP" $) -}}
        {{- $no_proxy = printf "%s,%s" $no_proxy . -}}
      {{- end -}}
      {{- with $kubernetes.networking.dnsDomain -}}
        {{- $no_proxy = printf "%s,%s,%s." $no_proxy . . -}}
      {{- end -}}
      {{/* Inject Subnet CIDRs (GO will understand, not bash) */}}
      {{- with $kubernetes.networking.podSubnet -}}
        {{- $no_proxy = printf "%s,%s" $no_proxy . -}}
      {{- end -}}
      {{- with $kubernetes.networking.serviceSubnet -}}
        {{- $no_proxy = printf "%s,%s" $no_proxy . -}}
      {{- end -}}
    {{- end -}}

    {{/* Machine Controller Component (Admission) */}}
    {{- if (include "machine-controller.admission-enabled" $) -}}
      {{- with (include "machine-controller.admission.endpoint" $) -}}
        {{- $no_proxy = printf "%s,%s" $no_proxy . -}}
      {{- end -}}
    {{- end -}}

    {{/* Operating System Manager Component (Admission) */}}
    {{- if (include "operating-system-manager.admission-enabled" $) -}}
      {{- with (include "operating-system-manager.admission.endpoint" $) -}}
        {{- $no_proxy = printf "%s,%s" $no_proxy . -}}
      {{- end -}}
    {{- end -}}

    {{/*{{- $no_proxy = printf "%s,%s" ($no_proxy | trimSuffix ",") "argocd-applicationset-controller,argocd-dex-server,argocd-redis,argocd-repo-server,argocd-server" -}}*/}}
  {{- end -}}

  {{- printf "%s" $no_proxy -}}
{{- end -}}

{{/* Proxy as Environment */}}
{{- define "pkg.common.proxy.env" -}}
  {{- if (include "pkg.common.proxy.enabled" $) -}}
    {{- with (include "pkg.common.proxy.host" $) }}
- name: "HTTP_PROXY"
  value: {{ . | quote }}
- name: "http_proxy"
  value: {{ . | quote }}
- name: "HTTPS_PROXY"
  value: {{ . | quote }}
- name: "https_proxy"
  value: {{ . | quote }}
    {{- end }}
    {{- with (include "pkg.common.proxy.no_proxy" $) }}
- name: "NO_PROXY"
  value: {{ . | quote }}
- name: "no_proxy"
  value: {{ . | quote }}
    {{- end }}
  {{- end -}}
{{- end -}}

{{/*
  ServiceMonitor ExtraLabels
*/}}
{{- define "pkg.common.sm.podTargetLabels" -}}
- {{ include "pkg.common.labels.part-of" $ | quote }}
- {{ include "pkg.common.labels.component" $ | quote }}
- {{ include "pkg.common.labels.name" $ | quote }}
{{- end -}}
