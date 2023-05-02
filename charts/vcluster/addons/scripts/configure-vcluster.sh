{{- $kubernetes := $.Values.kubernetes -}}
{{- $fullName := include "kubernetes.fullname" . -}}
{{- $lifecycle := $.Values.lifecycle -}}
#!/bin/bash
ENDPOINT=$(awk -F'[ "]+' '$1 == "controlPlaneEndpoint:" {print $2}' /config/kubeadmcfg.yaml)
# Decrypt Cert Data to Base64
CA=$(base64 /pki/admin-client/ca.crt | tr -d '\n')
C_CERT=$(base64 /pki/admin-client/tls.crt | tr -d '\n')
C_KEY=$(base64 /pki/admin-client/tls.key | tr -d '\n')

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
{{- include "pkg.functions.kubernetes" $ | nindent 0 }}

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

{{- if and $kubernetes.konnectivity.enabled $kubernetes.konnectivity.server.enabled }}{{"\n"}}
# install konnectivity server
kubectl apply -f /manifests/konnectivity-server.yaml
{{- else }}{{"\n"}}
kubectl delete ClusterRoleBinding ystem:konnectivity-server || true
{{- end }}


{{- if and $kubernetes.konnectivity.enabled $kubernetes.konnectivity.agent.enabled }}{{"\n"}}
# install konnectivity agent
kubectl apply -f /manifests/konnectivity-agent.yaml
{{- else }}{{"\n"}}
# uninstall konnectivity agent
kubectl delete sa/ 2>/dev/null || true
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

{{- $job := $.Values.lifecycle }}
{{- if $job.cilium.enabled }}
if kubectl get ds cilium -n kube-system &> /dev/null; then
	echo "Cilium already installed"
else 
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
fi
{{- end }}

# ------------------------------------------------------------------------------
# Machine Controller
# ------------------------------------------------------------------------------
{{- include "machine-controller.ensure-resources" $ | nindent 0 }}

# ------------------------------------------------------------------------------
# Operating System Manager
# ------------------------------------------------------------------------------
{{- include "operating-system-manager.ensure-resources" $ | nindent 0 }}

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
