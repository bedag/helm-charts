
{{/* Kubeconfig Template (Cert Auth) */}}
{{- define "pkg.kubeconfigs.kubeconfig.certs" -}}
{{- include "pkg.kubeconfigs.kubeconfig.base" $ | nindent 0 }}
    client-certificate-data: "${C_CERT}"
    client-key-data: "${C_KEY}"
{{- end -}}

{{/* Kubeconfig Template (Token Auth) */}}
{{- define "pkg.kubeconfigs.kubeconfig.token" -}}
{{- include "pkg.kubeconfigs.kubeconfig.base" $ | nindent 0 }}
    token: ${TOKEN}
{{- end -}}

{{/* Kubeconfig Template */}}
{{- define "pkg.kubeconfigs.kubeconfig.base" -}}
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CA}
    server: {{ default (include "pkg.cluster.endpoint.internal" $.ctx) $.endpoint }}
  name: default-cluster
contexts:
- context:
    cluster: default-cluster
    namespace: default
    user: default-auth
  name: default-context
current-context: default-context
kind: Config
preferences: {}
users:
- name: default-auth
  user:
{{- end -}}

{{/* Kubeconfig Argo Template */}}
{{- define "pkg.kubeconfigs.argo" -}}
name: {{ default (include "pkg.cluster.name" $.ctx) $.name }}
server: {{ default (include "pkg.cluster.endpoint.internal" $.ctx) $.endpoint }}
config: |
  {
    "tlsClientConfig": {
      "insecure": false,
      "caData": "${CA}",
      "keyData": "${C_KEY}",
      "certData": "${C_CERT}"
    }
  }
{{- end -}}
