{{/*
    Cluster Name
*/}}
{{- define "pkg.cluster.name" -}}
  {{- default $.Release.Name $.Values.cluster.name -}}
{{- end -}}

{{/*
    Namespace within cluster for management resources
*/}}
{{- define "pkg.cluster.namespace" -}}
kube-system
{{- end -}}

{{/*
  API Server Endpoint (internal)
    Requires .svc as noproxy on the kustomize controller, if proxy set
*/}}
{{- define "pkg.cluster.endpoint.internal" -}}
https://{{ include "pkg.cluster.name" $ }}-kubernetes-apiserver.{{ .Release.Namespace }}.svc:6443
{{- end -}}

{{/*
  API Server Endpoint (local)
*/}}
{{- define "pkg.cluster.endpoint.local" -}}
https://kubernetes.default.svc
{{- end -}}

{{/*
    Cluster Access (Volumes)
*/}}
{{- define "pkg.cluster.admin.cfg" -}}
{{ include "pkg.cluster.name" $ }}-kubernetes-kubeconfig
{{- end -}}

{{/*
    Cluster Access (Volumes)
*/}}
{{- define "pkg.cluster.cp.vs" -}}
- name: kubeconfig
  configMap:
    defaultMode: 420
    name: {{ include "pkg.cluster.admin.cfg" $ }}
- name: pki-admin-client
  secret:
    defaultMode: 420
    secretName: {{ include "pkg.cluster.name" $ }}-kubernetes-pki-admin-client
{{- end -}}

{{/*
    Kubconfig VolumeMount (Volumemounts)
*/}}
{{- define "pkg.cluster.cp.vms" -}}
- mountPath: /etc/kubernetes
  name: kubeconfig
  readOnly: true
- mountPath: /pki/admin-client
  name: pki-admin-client
{{- end -}}

{{/*
    Kubconfig Environment
*/}}
{{- define "pkg.cluster.cp.env" -}}
- name: KUBECONFIG
  value: {{ template "pkg.cluster.cp.env.mount" $ }}
{{- end -}}


{{/*
    Kubconfig Environment
*/}}
{{- define "pkg.cluster.cp.env.mount" -}}
/etc/kubernetes/admin.conf
{{- end -}}

{{/*
    Connectivity Container
*/}}
{{- define "pkg.cluster.connectivity" -}}
  {{- $manifest := $.connectivity -}}
- name: connectivity
  image: {{ include "pkg.images.registry.convert" (dict "image" $manifest.image "ctx" $.ctx) }}
  imagePullPolicy: {{ include "pkg.images.registry.pullpolicy" (dict "policy" $manifest.image.pullPolicy "ctx" $.ctx) }}
  env: {{- include "pkg.common.env" $.ctx | nindent 4 }}
  {{- include "pkg.cluster.cp.env" $.ctx | nindent 4 }}
  {{- with (include "pkg.components.securityContext" (dict "sc" $manifest.securityContext "ctx" $.ctx)) }}
  securityContext: {{ . | nindent 4 }}
  {{- end }}
  {{- with $manifest.resources }}
  resources: {{ . | nindent 4 }}
  {{- end }}
  command:
    - sh
    - -c
    - |
        # Wait for cluster Connectivity
        echo "Waiting for api-server endpoint ..."
        until kubectl cluster-info >/dev/null 2>/dev/null; do
          sleep 3
        done
  volumeMounts: {{- include "pkg.cluster.cp.vms" $.ctx | nindent 4 }}
{{- end }}
