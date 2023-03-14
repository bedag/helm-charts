{{- $kubernetes := $.Values.kubernetes -}}
{{- $fullName := include "kubernetes.fullname" . -}}
{{- $lifecycle := $.Values.lifecycle -}}
{{- $argocd := $.Values.gitops.argocd -}}
#!/bin/bash
ENDPOINT=$(awk -F'[ "]+' '$1 == "controlPlaneEndpoint:" {print $2}' /config/kubeadmcfg.yaml)
# Decrypt Cert Data to Base64
CA=$(base64 /pki/admin-client/ca.crt | tr -d '\n')
C_CERT=$(base64 /pki/admin-client/tls.crt | tr -d '\n')
C_KEY=$(base64 /pki/admin-client/tls.key | tr -d '\n')

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
{{- include "gitops.converter.script.functions" $ | nindent 0 }}

# ------------------------------------------------------------------------------
# Cluster configuration
# ------------------------------------------------------------------------------
export KUBECONFIG=/etc/kubernetes/admin.conf

# upload configuration
# TODO: https://github.com/kvaps/kubernetes-in-kubernetes/issues/6
kubeadm init phase upload-config kubeadm --config /config/kubeadmcfg.yaml

# upload configuration
# TODO: https://github.com/kvaps/kubernetes-in-kubernetes/issues/5
kubeadm init phase upload-config kubelet --config /config/kubeadmcfg.yaml -v1 2>&1 |
  while read line; do echo "$line" | grep 'Preserving the CRISocket information for the control-plane node' && killall kubeadm || echo "$line"; done

# setup bootstrap-tokens
# TODO: https://github.com/kvaps/kubernetes-in-kubernetes/issues/7
# TODO: https://github.com/kubernetes/kubernetes/issues/98881
flatconfig=$(mktemp)
kubectl config view --flatten > "$flatconfig"
kubeadm init phase bootstrap-token --config /config/kubeadmcfg.yaml --skip-token-print --kubeconfig="$flatconfig"
rm -f "$flatconfig"

# correct apiserver address for the external clients
kubectl apply -n kube-public -f - <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-info
data:
  kubeconfig: |
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: $(base64 /pki/admin-client/ca.crt | tr -d '\n')
        server: https://${ENDPOINT}
      name: ""
    contexts: null
    current-context: ""
    kind: Config
    preferences: {}
    users: null
EOT

{{- if (include "pkg.images.registry.auth" $) }}
# Ensure dockerconfig is present
kubectl apply -f /manifests/regcred.yaml
{{- else }}{{"\n"}}
kubectl delete secret {{ include "pkg.images.registry.secretname" $ }} -n {{ include "pkg.images.registry.secretnamespace" $ }} 2>/dev/null || true
{{- end }}

{{- if $kubernetes.konnectivityServer.enabled }}{{"\n"}}
# install konnectivity server
kubectl apply -f /manifests/konnectivity-server-rbac.yaml
{{- else }}{{"\n"}}
kubectl delete -f /manifests/konnectivity-server-rbac.yaml 2>/dev/null || true
{{- end }}

{{- if $kubernetes.konnectivityAgent.enabled }}{{"\n"}}
# install konnectivity agent
kubectl apply -f /manifests/konnectivity-agent-deployment.yaml -f /manifests/konnectivity-agent-rbac.yaml
{{- else }}{{"\n"}}
# uninstall konnectivity agent
kubectl delete -f /manifests/konnectivity-agent-deployment.yaml -f /manifests/konnectivity-agent-rbac.yaml 2>/dev/null || true
{{- end }}

{{- if $kubernetes.coredns.enabled }}{{"\n"}}
# install coredns addon
kubectl apply -f /manifests/coredns.yaml
{{- else }}{{"\n"}}
# uninstall coredns addon
kubectl delete -f /manifests/coredns.yaml 2>/dev/null || true
{{- end }}

{{- if $kubernetes.kubeProxy.enabled }}{{"\n"}}
# install kube-proxy addon
# TODO: https://github.com/kvaps/kubernetes-in-kubernetes/issues/4
kubeadm init phase addon kube-proxy --config /config/kubeadmcfg.yaml
{{- else }}{{"\n"}}
# uninstall kube-proxy addon
kubectl -n kube-system delete configmap/kube-proxy daemonset/kube-proxy 2>/dev/null || true
{{- end }}

{{- $job := $.Values.jobs }}
{{- if $job.cilium.enabled }}
  {{- if or (and ($job.cilium.on_install) ($.Release.IsInstall)) (not $job.cilium.on_install) }}
# install cilium
helm repo add cilium https://helm.cilium.io/
helm upgrade --install cilium cilium/cilium {{ with $job.cilium.version }}--version {{ . }} {{ end }} \
    {{- if not ($kubernetes.kubeProxy.enabled) }}
    --set kubeProxyReplacement=strict \
      {{- if $kubernetes.controlPlaneEndpoint }}
    --set k8sServiceHost={{ include "kubernetes.api.endpointIP" $ }} \
    --set k8sServicePort={{ include "kubernetes.api.endpointPort" $ }} \
      {{- else }}
    --set k8sServiceHost={{ $fullName }}-apiserver \
    --set k8sServicePort={{ $kubernetes.apiServer.service.port }} \
      {{- end }}
    {{- end }}
    --namespace kube-system
  {{- end }}
{{- end }}

# ------------------------------------------------------------------------------
# Machine Controller
# ------------------------------------------------------------------------------
{{- include "machine-controller.ensure-resources" $ | nindent 0 }}

# ------------------------------------------------------------------------------
# Operating System Manager
# ------------------------------------------------------------------------------
{{- include "operating-system-manager.ensure-resources" $ | nindent 0 }}

# ------------------------------------------------------------------------------
# GitOps
# ------------------------------------------------------------------------------
{{- include "gitops.ensure-resources" $ | nindent 0 }}

# Ensure Chart Managed Resources
{{- with $argocd.bootstrap }}
helm repo add argocd {{ .repoURL }}
{{- end }}

{{- if (include "gitops.enabled" $) }}

# Pre-Create Namespace
kubectl create ns {{ include "pkg.argo.ns" $ }} > /dev/null

{{- if $argocd.bootstrap.config.register.enabled }}
# Register Cluster
cluster_cfg=$(cat <<EOT
---
apiVersion: v1
kind: Secret
metadata:
  name: "register-vcluster"
  namespace: {{ include "pkg.argo.ns" $ }}
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: {{ $argocd.bootstrap.config.register.name }}
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
EOT
)
k8s::replace_or_create "$cluster_cfg"
{{- else }}
kubectl delete secret register-vcluster -n {{ include "pkg.argo.ns" $ }} | true
{{- end }}


# Check Templating is valid
if {{ include "pkg.argo.template-cmd" $ }} > /dev/null; then
  values=$({{- include "pkg.argo.template-cmd" $ }} --set crds.install="true")

  {{- if $argocd.bootstrap.config.install_crds }}
  # Apply CRDs
  crds=$(echo "$values" | yq '. | select(.kind == "CustomResourceDefinition")')
  if ! [ -z "$crds" ]; then
    echo "$crds" | kubectl apply -n {{ include "pkg.argo.ns" $ }} --server-side=true -f -
  fi
  {{- end }}

  # Apply Argo Configmap
  cm=$(echo "$values" | yq '. | select(.kind == "ConfigMap" and .metadata.name == "argocd-cm")')
  if ! [ -z "$cm" ]; then
    echo "$cm" | kubectl apply -n {{ include "pkg.argo.ns" $ }} --server-side=true -f -
  fi

  # Apply Argo Secret
  sec=$(echo "$values" | yq '. | select(.kind == "Secret" and .metadata.name == "argocd-secret")')
  if ! [ -z "$sec" ]; then
    echo "$sec" | kubectl apply -n {{ include "pkg.argo.ns" $ }} --server-side=true -f -
  fi

fi

{{- else }}
  {{- if $.Values.gitops.component.removeManifestsOnDisable }}
# Remove Argo Configmap
kubectl delete cm argocd-cm -n {{ include "pkg.argo.ns" $ }} | true
# Apply Argo Secret
kubectl delete secret argocd-secret -n {{ include "pkg.argo.ns" $ }} | true
  {{- end }}
{{- end }}

{{- with $lifecycle.vcluster.script }}
# ------------------------------------------------------------------------------
# Additional Script
# ------------------------------------------------------------------------------
{{- include "pkg.utils.template" (dict "tpl" . "ctx" $) | nindent 0 }}
{{- end }}

# ------------------------------------------------------------------------------
# Additional Manifests
# ------------------------------------------------------------------------------
{{- if $.Release.IsInstall }}
  {{- with $lifecycle.vcluster.extraManifestsOnInstall }}
kubectl apply{{- range $key, $value := . }} -f /manifests/{{ $key }} {{- end }}
  {{- end }}
{{- end }}

{{- with $lifecycle.vcluster.extraManifests }}
kubectl apply{{- range $key, $value := . }} -f /manifests/{{ $key }} {{- end }}
{{- end }}
