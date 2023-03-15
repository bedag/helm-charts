{{/*
Component enabled
*/}}
{{- define "gitops.enabled" -}}
{{- $component := $.Values.gitops -}}
  {{- if $component.enabled -}}
    {{- true -}}
  {{- end -}}
{{- end }}

{{/*
Component Manifests directory
*/}}
{{- define "gitops.manifests.dir" -}}
{{- printf "manifests/%s/" (include "gitops.component" $) -}}
{{- end }}

{{/*
Component Manifests
*/}}
{{- define "gitops.manifests" -}}
{{- printf "%s/**.yaml" (include "gitops.manifests.dir" $) -}}
{{- end }}


{{/*
Component Manifests Configmap/Secret name
*/}}
{{- define "gitops.manifests.name" -}}
{{- printf "%s-manifests" (include "gitops.fullname" $) -}}
{{- end }}

{{/*
  Component
*/}}
{{- define "gitops.component" -}}
gitops
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "gitops.name" -}}
{{- include "gitops.component" $ -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gitops.fullname" -}}
{{- $name := include "gitops.component" $ }}
{{- printf "%s-%s" (include "pkg.cluster.name" $) $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Base labels (Base)
*/}}
{{- define "gitops.labels" -}}
{{ include "pkg.common.labels" $ }}
{{ include "gitops.selectorLabels" $ }}
{{- end }}

{{/*
  Selector labels (Base)
*/}}
{{- define "gitops.selectorLabels" -}}
{{ include "pkg.common.labels.part-of" $ }}: {{ include "gitops.component" $ }}
{{ include "pkg.common.labels.component" $ }}: {{ include "gitops.component" $ }}
{{ include "pkg.common.selectors" $ }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gitops.serviceAccountName" -}}
{{- $manifest := $.Values.gitops -}}
{{- if $manifest.serviceAccount.create }}
{{- default (include "gitops.fullname" $) $manifest.serviceAccount.name }}
{{- else }}
{{- default "default" $manifest.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
    Manifests Checksum
*/}}
{{- define "gitops.manifests.checksum" -}}
checksum/manifests: {{ (.Files.Glob (printf "%s/manifests/**.yaml" (include "components.gitops.dir" $)) | toYaml | sha256sum | quote) }}
{{- end }}



{{/* Volumes for Admission Pod */}}
{{- define "gitops.volumes" -}}
- name: gitops-manifests
  secret:
    defaultMode: 420
    secretName: {{ include "gitops.manifests.name" $ }}
{{- end -}}


{{/* VolumeMounts */}}
{{- define "gitops.volumemounts" -}}
- name: gitops-manifests
  mountPath: {{ include "gitops.volumemounts.manifests.path" $ }}
  readOnly: true
{{- end -}}

{{/* MountPath for Manifests */}}
{{- define "gitops.volumemounts.manifests.path" -}}
/tmp/gitops/manifests/
{{- end -}}

{{/*
  Ensure All
*/}}
{{- define "gitops.ensure-resources" -}}
  {{- include "gitops.manifest-create" $ | nindent 0 }}
{{- end -}}

{{/*
  Ensure Manifests
*/}}
{{- define "gitops.manifest-create" -}}
  {{- if (include "gitops.manifest-exist" $) -}}
if ! [ `find {{ include "gitops.volumemounts.manifests.path" $ }} -prune -empty 2>/dev/null` ]; then
    {{- if (include "gitops.enabled" $) }}
  # Apply Machine Controller Manifests
  kubectl apply -f {{ include "gitops.volumemounts.manifests.path" $ }}
    {{- else }}
      {{- if $.Values.gitops.component.removeManifestsOnDisable }}
  # Delete Machine Controller Manifests
  kubectl delete -f {{ include "gitops.volumemounts.manifests.path" $ }} 2>/dev/null || true
      {{- end }}
    {{- end }}
fi
  {{- end }}
{{- end -}}


{{/*
 Validate if any Manifests are rendered
*/}}
{{- define "gitops.manifest-exist" -}}
  {{- $files := .Files.Glob (include "gitops.manifests" $) -}}
  {{- if $files -}}
    {{- true -}}
  {{- end -}}
{{- end -}}


{{/*
    Flux Enabled indicator
*/}}
{{- define "gitops.flux.enabled" -}}
  {{- $manifest := $.Values.gitops -}}
  {{- if $manifest.flux.enabled -}}
    {{- true -}}
  {{- end -}}
{{- end -}}


{{/*
  Kubeconfig Secret Name (Flux)
*/}}
{{- define "gitops.converter.flux.secretName" -}}
{{- printf "%s-kubernetes-admin-flux" (include "pkg.cluster.name" $) -}}
{{- end -}}

{{/*
  Kubeconfig Secret Name (Flux)
*/}}
{{- define "gitops.converter.argocd.secretName" -}}
{{- printf "%s-kubernetes-admin-argocd" (include "pkg.cluster.name" $) -}}
{{- end -}}

{{/*
  Kubeconfig Secret Key
*/}}
{{- define "gitops.converter.secretKey" -}}
kubeconfig
{{- end -}}


{{/*
  Useful Script Functions
*/}}
{{- define "gitops.converter.script.functions" -}}
# Perform Client Dry-Run
k8s::dry-run() {
  object=${1}
  if kubectl create --dry-run=client -f - <<< "$object" >/dev/null; then
    return 0
  else
    return 1
  fi
}

# Always Updates Object
k8s::replace_or_create() {
  object=${1}
  if k8s::dry-run "${object}"; then
    if ! kubectl get -f - <<< "$object" >/dev/null 2>/dev/null; then
      if kubectl create -f - <<< "$object" >/dev/null; then
        echo "🦄 Created Object"
        return 0
      else
        return 1
      fi
    else
      if kubectl replace --force -f - <<< "$object" >/dev/null; then
        echo "🦄 Updated Object"
      else
        return 1
      fi
      return 0
    fi
  else
    return 1
  fi
}

## Create an Object if it does not exist
k8s::create_if_not_present() {
  object=${1}
  if k8s::dry-run "${object}"; then
    if kubectl create --dry-run=server -f - <<< "$object" >/dev/null 2>/dev/null; then
      kubectl create -f - <<< "$object" >/dev/null
      echo "🦄 Created Object"
      return 0
    else
      echo "🦄 Object already present"
      return 0
    fi
  else
    return 1
  fi
}

## Set Kubeconfig (Use Mounted)
kcfg::toggle() {
  export KUBECONFIG="{{ template "pkg.cluster.cp.env.mount" $ }}"
}

## Unset Kubeconfig (Use Serviceaccount)
kcfg::untoggle() {
  unset KUBECONFIG
}
{{- end -}}

{{/* Template fpr Flux Cluster Secret */}}
{{- define "gitops.converter.script.tpl.flux" -}}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "gitops.converter.flux.secretName" $ }}
  labels: {{- include "gitops.labels" . | nindent 4 }}
  namespace: {{ .Release.Namespace }}
stringData:
  {{- include "gitops.converter.secretKey" $ | nindent 2 }}: |
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: ${CA}
        server: {{ include "pkg.cluster.endpoint.internal" $ }}
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
        client-certificate-data: "${C_CERT}"
        client-key-data: "${C_KEY}"
{{- end -}}


{{/* Template for ArgoCD Cluster Secret */}}
{{- define "gitops.converter.script.tpl.argo" -}}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "gitops.converter.argocd.secretName" $ }}
  namespace: {{ $.Release.Namespace}}
  labels: {{- include "gitops.labels" . | nindent 4 }}
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: {{ include "pkg.cluster.name" $ }}
  server: {{ include "pkg.cluster.endpoint.internal" $ }}
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



{{/*
   Inventory Sync Ref
*/}}
{{- define "gitops.inventory.reference" -}}
  {{- $manifest := $.Values.gitops -}}
  {{- with $manifest.inventory.repository.ref -}}
    {{- (tpl . $) -}}
  {{- end -}}
{{- end -}}

{{/*
    Inventory Sync Path
*/}}
{{- define "gitops.inventory.path" -}}
  {{- $manifest := $.Values.gitops -}}
  {{- $path := printf "./clusters/%s" (include "pkg.cluster.name" $) -}}
  {{- with $manifest.inventory.repository.path -}}
    {{- $path = (tpl . $) -}}
  {{- end -}}
  {{- $path -}}
{{- end -}}

{{/*
    Substitution Variables
*/}}
{{- define "gitops.substition.variables" -}}

  {{/* Custom Properties */}}
  {{- include  "gitops.substition.properties" $ | nindent 0 }}

  {{/* Common Variables */}}
cluster_name: {{ include "pkg.cluster.name" $ }}
  {{- with (include "pkg.argo.destination" $) }}
argo_cluster_name: {{ . }}
  {{- end }}
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

{{/*
    Substitution Variables (Evnironment Variables)
*/}}
{{- define "gitops.substition.variables.env" -}}
  {{- $vars := (fromYaml (include "gitops.substition.variables" $)) -}}
  {{- range $key, $value := $vars }}
- name: {{ $key }}
  value: {{ $value | quote }}
  {{- end -}}
{{- end -}}


{{- define "gitops.substition.properties" -}}
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
