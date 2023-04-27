{{- $manifest := $.Values.gitops -}}
{{- $argocd := $manifest.argocd -}}
{{- $lifecycle := $.Values.lifecycle -}}
#!/bin/bash

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
{{- include "gitops.converter.script.functions" $ | nindent 0 }}

# ------------------------------------------------------------------------------
# GitOps Setup
# ------------------------------------------------------------------------------

# -- Convert Kubeconfigs

UID=$(kubectl get cm -n {{ $.Release.Namespace }} {{ include "pkg.cluster.admin.cfg" $ }} -o jsonpath='{.metadata.uid}') || true

# Decrypt Cert Data to Base64
CA=$(base64 /pki/admin-client/ca.crt | tr -d '\n')
C_CERT=$(base64 /pki/admin-client/tls.crt | tr -d '\n')
C_KEY=$(base64 /pki/admin-client/tls.key | tr -d '\n')

{{- $kubeconfigs := $.Values.lifecycle.kubeconfigs }}

{{- if (include "gitops.enabled" $) }}{{"\n"}}
  {{/* Add Default Flux Kubeconfig */}}
  {{- $kubeconfigs = append $kubeconfigs (dict "name" (include "gitops.converter.flux.secretName" $) "key" (include "gitops.converter.secretKey" $)) }}

  {{/* Add Default Argo Kubeconfig */}}
  {{- $kubeconfigs = append $kubeconfigs (dict "name" (include "gitops.converter.argocd.secretName" $) "type" "argo") }}
{{- end -}}{{"\n"}}

# Iterate over all kubeconfigs
{{- range $kubeconfigs }}{{"\n"}}
  {{- $name := (include "pkg.utils.template" (dict "tpl" (required "kubeconfig.name is required" .name) "ctx" $)) -}}
  {{- $namespace := default $.Release.Namespace .namespace -}}
  {{- $key := default "kubeconfig" .key -}}
  {{- $type := default "kubeconfig" .type | lower -}}
  {{- $kind := default "Secret" .kind | lower -}}
  {{- $endpoint := default "" .endpoint | lower -}}
  {{- if (eq $endpoint "external") -}}
    {{- $endpoint = (include "kubernetes.api.endpoint" $) -}}
  {{- end -}}
KCFG=$(cat <<EOT
---
apiVersion: v1
metadata:
  name: {{ $name }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "vcluster.labels" $ | nindent 4 }}
    {{- if .labels }}
      {{- toYaml .labels | nindent 4 }}
    {{- end }}
    {{- if (eq $type "argo") }}
    argocd.argoproj.io/secret-type: cluster
    {{- end }}
  namespace: {{ $namespace }}
  {{- if .ownerref }}
  ownerReferences:
  - apiVersion: v1
    kind: ConfigMap
    name: {{ include "pkg.cluster.admin.cfg" $ }}
    uid: "${UID}"
  {{- end }}
{{- if (eq $kind "configmap") }}
kind: ConfigMap
data:
{{- else }}
kind: Secret
stringData:
{{- end }}
{{- if (eq $type "argo") }}
  {{- include "pkg.kubeconfigs.argo" (dict "name" (default $name .clustername) "endpoint" $endpoint "ctx" $) | nindent 2 }}
{{- else }}
  {{- default "kubeconfig" $key | nindent 2 }}: |
    {{- include "pkg.kubeconfigs.kubeconfig.certs" (dict "endpoint" $endpoint "ctx" $) | nindent 4 }}
{{- end }}
EOT
)

if k8s::replace_or_create "${KCFG}"; then
  echo "✅ ({{ $namespace }}/{{ $name }}) Kubeconfig Present"
else
  echo "🔥 ({{ $namespace }}/{{ $name }}) Kubeconfig Not Present"
fi
{{- end }}

{{- with $lifecycle.current.script }}
# ------------------------------------------------------------------------------
# Additional Script
# ------------------------------------------------------------------------------
{{- include "pkg.utils.template" (dict "tpl" . "ctx" $) | nindent 0 }}
{{- end }}
