{{/*
Component enabled
*/}}
{{- define "machine-controller.enabled" -}}
{{- $component := $.Values.machine -}}
  {{- if $component.enabled -}}
    {{- true -}}
  {{- end -}}
{{- end }}

{{/*
Component Manifests Configmap/Secret name
*/}}
{{- define "machine-controller.manifests.name" -}}
{{- printf "%s-manifests" (include "machine-controller.fullname" $) -}}
{{- end }}

{{/*
Component Manifests directory
*/}}
{{- define "machine-controller.manifests.dir" -}}
{{- printf "manifests/%s" (include "machine-controller.component" $) -}}
{{- end }}

{{/*
Component Manifests directory
*/}}
{{- define "machine-controller.manifests" -}}
{{- printf "%s/**.yaml" (include "machine-controller.manifests.dir" $) -}}
{{- end }}

{{/*
Component Webhook directory
*/}}
{{- define "machine-controller.webhooks.dir" -}}
{{- printf "webhooks/%s" (include "machine-controller.component" $) -}}
{{- end }}


{{/*
Component Webhook directory
*/}}
{{- define "machine-controller.webhooks" -}}
{{- printf "%s/**.yaml" (include "machine-controller.webhooks.dir" $) -}}
{{- end }}

{{/*
  Component
*/}}
{{- define "machine-controller.component" -}}
machine-controller
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "machine-controller.name" -}}
{{- include "machine-controller.component" $ -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "machine-controller.fullname" -}}
{{- $name := include "machine-controller.component" $ }}
{{- printf "%s-%s" (include "pkg.cluster.name" $) $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Base labels (Base)
*/}}
{{- define "machine-controller.labels" -}}
{{ include "pkg.common.labels" $ }}
{{ include "machine-controller.selectorLabels" $ }}
{{- end }}

{{/*
  Selector labels (Base)
*/}}
{{- define "machine-controller.selectorLabels" -}}
{{ include "pkg.common.labels.part-of" $ }}: {{ include "machine-controller.component" $ }}
{{ include "pkg.common.labels.component" $ }}: {{ include "machine-controller.component" $ }}
{{ include "pkg.common.selectors" $ }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "machine-controller.serviceAccountName" -}}
{{- $machine := $.Values.machine -}}
{{- if $machine.serviceAccount.create }}
{{- default (include "machine-controller.fullname" $) $machine.serviceAccount.name }}
{{- else }}
{{- default "default" $machine.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  Returns True if Admission Webhook is enabled
*/}}
{{- define "machine-controller.admission-enabled" -}}
  {{- if (include "machine-controller.enabled" $) -}}
    {{- $machine := $.Values.machine -}}
    {{- if $machine.admission.enabled -}}
      {{- true -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
Create the Admission Webhook TLS Secret
*/}}
{{- define "machine-controller.secretTlsName" -}}
  {{- if (include "machine-controller.admission.expose.ingress" $) }}
{{- include "pkg.components.certificates.secretTlsName" $ }}
  {{- else }}
{{- include "machine-controller.admission.secretTlsName" $ }}
  {{- end }}
{{- end }}

{{/*
Self-Signed Admission Webhook TLS Secret
*/}}
{{- define "machine-controller.admission.secretTlsName" -}}
{{- $machine := $.Values.machine -}}
{{ default ( printf "%s-tls" ( include "machine-controller.fullname" . ) ) $machine.admission.webhook.tls.name }}
{{- end }}

{{/*
    Manifests Checksum
*/}}
{{- define "machine-controller.manifests.checksum" -}}
checksum/manifests: {{ (.Files.Glob (include "machine-controller.manifests" $) | toYaml | sha256sum | quote) }}
{{- end }}

{{/*
    Webhook Checksum
*/}}
{{- define "machine-controller.webhooks.checksum" -}}
checksum/webhooks: {{ (.Files.Glob (include "machine-controller.webhooks" $) | toYaml | sha256sum | quote) }}
{{- end }}

{{/*
    Common Controller Arguments
*/}}
{{- define "machine-controller.controller.args" -}}
- -kubeconfig={{ include "pkg.cluster.cp.env.mount" $ }}
- -logtostderr
  {{- if (include "pkg.common.proxy.enabled" $) }}
    {{- with (include "pkg.common.proxy.host" $) }}
- -node-http-proxy={{ . }}
      {{- with (include "pkg.common.proxy.no_proxy" $) }}
- -node-no-proxy={{ . | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if (include "pkg.images.registry.set" $) }}
- -node-registry-mirrors={{ include "pkg.images.registry.url" $ }}
#- -node-containerd-registry-mirrors
    {{- if (include "pkg.images.registry.auth" $) }}
- -node-registry-credentials-secret={{ include "pkg.images.registry.secretnamespace" $ }}/regcreds
    {{- end }}
  {{- end }}
- -cluster-dns={{ include "kubernetes.getCoreDNS" $ }}
- -override-bootstrap-kubelet-apiserver={{ include "kubernetes.api.endpoint" $ }}
  {{- with $.Values.machine.kubelet.featureGates }}
- -node-kubelet-feature-gates={{ . | join "," | quote }}
  {{- end }}
{{- end -}}

{{/*
    Pause Image / OSM Compatible
*/}}
{{- define "machine-controller.pause" -}}
{{- $machine := $.Values.machine -}}
  {{- with $machine.pause }}
    {{- include "pkg.images.registry.convert" (dict "image" .image "ctx" $) -}}
  {{- end }}
{{- end }}


{{/*
    Runtime / OSM Compatible
*/}}
{{- define "machine-controller.runtime" -}}
{{- $machine := $.Values.machine -}}
  {{- with $machine.runtime }}
    {{- printf "%s" . -}}
  {{- end }}
{{- end }}


{{/*
Create the Admission Webhook Name
*/}}
{{- define "machine-controller.admission.mutating-webhook-name" -}}
machine-controller-mutating-webhook
{{- end -}}

{{/*
  Admission URL
*/}}
{{- define "machine-controller.admission.url" -}}

  {{/* If not enabled, use undefined in url (otherwise delete will fail) */}}
  {{- $base := "undefined" -}}

  {{- if (include "machine-controller.admission-enabled" $) -}}
    {{/* Expose via Ingress */}}
    {{- if (include "machine-controller.admission.expose.ingress" $) -}}
      {{- $base = (printf "https://%s/%s" (include "pkg.components.ingress.host" $) (include "machine-controller.admission.expose.ingress.context" $ | trimPrefix "/")) -}}
    {{- end -}}
  
    {{/* Expose via Service (LoadBalancer) */}}
    {{- if (include "machine-controller.admission.expose.loadbalancer" $) -}}
      {{- $base = (printf "https://%s:%s" (include "machine-controller.admission.expose.loadbalancer.ip" $) (include "machine-controller.admission.expose.loadbalancer.port" $)) -}}
    {{- end -}}
  {{- end -}}

  {{/* Print */}}
  {{- if $base -}}
    {{- (printf "%s" $base) | trimAll "/" -}}
  {{- end -}}
{{- end -}}

{{- define "machine-controller.admission.endpoint" -}}
  {{/* Expose via Ingress */}}
  {{- if (include "machine-controller.admission.expose.ingress" $) -}}
    {{- printf "%s" (include "pkg.components.ingress.host" $) -}}
  {{- else if (include "machine-controller.admission.expose.loadbalancer" $) -}}
    {{- printf "%s" (include "machine-controller.admission.expose.loadbalancer.ip" $) -}}
  {{- end -}}
{{- end -}}

{{/*
Admission Expose
*/}}
{{- define "machine-controller.admission.expose.loadbalancer" -}}
  {{- $machine := $.Values.machine -}}
  {{- if not (include "machine-controller.admission.expose.ingress" $) -}}
    {{- if (eq (include "pkg.components.expose.type" (dict "expose" $machine.admission.expose "ctx" $)) "loadbalancer") -}}
      {{- if (include "machine-controller.admission.expose.loadbalancer.ip" $) -}}
        {{- true -}}
      {{- else -}}
        {{- include "pkg.utils.fail" "LoadBalancerIP ($.Values.machine.admission.service.loadBalancerIP) must be defined for expose type loadbalancer" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "machine-controller.admission.expose.loadbalancer.ip" -}}
  {{- $machine := $.Values.machine -}}
  {{- with $machine.admission.service.loadBalancerIP -}}
    {{- printf "%s" . -}}
  {{- end -}}
{{- end -}}

{{- define "machine-controller.admission.expose.loadbalancer.port" -}}
  {{- $machine := $.Values.machine -}}
  {{- with $machine.admission.service.port -}}
    {{- . -}}
  {{- end -}}
{{- end -}}

{{- define "machine-controller.admission.expose.ingress" -}}
  {{- $machine := $.Values.machine -}}
  {{- if or (eq $.Values.global.components.exposure.expose "ingress") (eq $machine.admission.expose "ingress") -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{- define "machine-controller.admission.expose.ingress.context" -}}
  {{- $machine := $.Values.machine -}}
  {{- printf "%s" (required "Context Required" $machine.admission.ingress.contextPath) -}}
{{- end -}}


{{/* Volumes for Admission Pod */}}
{{- define "machine-controller.volumes" -}}
- name: machine-webhooks
  secret:
    defaultMode: 420
    secretName: {{ include "machine-controller.fullname" $ }}-webhooks
- name: machine-manifests
  secret:
    defaultMode: 420
    secretName: {{ include "machine-controller.manifests.name" $  }}
  {{- if (include "machine-controller.admission-enabled" $) }}
- name: machine-webhook-certs
  secret:
    defaultMode: 420
    secretName: {{ include "machine-controller.secretTlsName" $ }}
  {{- end }}
{{- end -}}

{{/* VolumeMounts for Admission Pod */}}
{{- define "machine-controller.volumemounts" -}}
- name: machine-webhooks
  mountPath: {{ include "machine-controller.volumemounts.webhooks.path" $ }}
  readOnly: true
- name: machine-manifests
  mountPath: {{ include "machine-controller.volumemounts.manifests.path" $ }}
  readOnly: true
  {{- include "machine-controller.volumemounts.certs" $ | nindent 0 }}
{{- end -}}

{{/* VolumeMounts for Admission Pod */}}
{{- define "machine-controller.volumemounts.certs" -}}
  {{- if (include "machine-controller.admission-enabled" $) }}
- mountPath: {{ include "machine-controller.volumemounts.certs.path" $ }}
  name: machine-webhook-certs
  readOnly: true
  {{- end }}
{{- end -}}

{{/* MountPath for certificates */}}
{{- define "machine-controller.volumemounts.certs.path" -}}
/tmp/machine/serving-certs/
{{- end -}}

{{/* MountPath for webhooks */}}
{{- define "machine-controller.volumemounts.webhooks.path" -}}
/tmp/machine/webhooks/
{{- end -}}

{{/* MountPath for Manifests */}}
{{- define "machine-controller.volumemounts.manifests.path" -}}
/tmp/machine/manifests/
{{- end -}}

{{/*
  Ensure All
*/}}
{{- define "machine-controller.ensure-resources" -}}
  {{- include "machine-controller.manifest-create" $ | nindent 0 }}
  {{- include "machine-controller.admission.webhook-cert-patch" $ | nindent 0 }}
{{- end -}}


{{/*
  Ensure Manifests
*/}}
{{- define "machine-controller.manifest-create" -}}
  {{- if (include "machine-controller.manifest-exist" $) -}}
if ! [ `find {{ include "machine-controller.volumemounts.manifests.path" $ }} -prune -empty 2>/dev/null` ]; then
    {{- if (include "machine-controller.enabled" $) }}
  # Apply Machine Controller Manifests
  kubectl apply -f {{ include "machine-controller.volumemounts.manifests.path" $ }}
    {{- else }}
      {{- if $.Values.machine.component.removeManifestsOnDisable }}
  # Delete Machine Controller Manifests
  kubectl delete -f {{ include "machine-controller.volumemounts.manifests.path" $ }} 2>/dev/null || true
      {{- end }}
    {{- end }}
fi
  {{- end -}}
{{- end -}}

{{/*
 Validate if any Manifests are rendered
*/}}
{{- define "machine-controller.manifest-exist" -}}
  {{- $files := .Files.Glob (include "machine-controller.manifests" $) -}}
  {{- if $files -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/*
  InitContainer to apply/delete manifests
*/}}
{{- define "machine-controller.manifest-init" -}}
  {{- $manifest := $.Values.lifecycle.job  -}}
  {{- if (include "machine-controller.manifest-exist" $) }}
- name: machine-manifests
  image: {{ include "pkg.images.registry.convert" (dict "image" $manifest.image "ctx" $) }}
  env: {{- include "pkg.common.env" $ | nindent 6 }}
    {{- include "pkg.cluster.cp.env" $ | nindent 6 }}
  {{- with (include "pkg.components.securityContext" (dict "sc" $manifest.securityContext "ctx" $)) }}
  securityContext: {{ . | nindent 4 }}
  {{- end }}
  {{- with $manifest.resources }}
  resources: {{ . | nindent 4 }}
  {{- end }}
  command:
    - /bin/sh
    - -c
    - |
        {{- include "machine-controller.ensure-resources" $ | nindent 8 }}
  volumeMounts: {{- include "pkg.cluster.cp.vms" $ | nindent 4 }}
    {{- include "machine-controller.volumemounts" $ | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
  Ensure Webhooks
*/}}
{{- define "machine-controller.admission.webhook-cert-patch" -}}
  {{- if not (include "machine-controller.admission-enabled" $) }}
# Remove Webhooks (Be explicit, since content may have changed)
kubectl delete mutatingwebhookconfiguration {{ include "machine-controller.admission.mutating-webhook-name" $ }} 2>/dev/null || true
  {{- else }}

# Ensure Webhooks are present
kubectl apply -f {{ include "machine-controller.volumemounts.webhooks.path" $ }}

# Export the CA bundle to a file (Must be single line)
export CA_BUNDLE=`openssl base64 -in {{ include "machine-controller.volumemounts.certs.path" $ }}tls.crt | tr -d '\n'`;

# Patch the CA bundle in the webhook configurations
kubectl patch MutatingWebhookConfiguration {{ include "machine-controller.admission.mutating-webhook-name" $ }} \
  --type='json' -p="[\
  	{'op': 'replace', 'path': '/webhooks/0/clientConfig/caBundle', 'value': \"${CA_BUNDLE}\"  },\
  	{'op': 'replace', 'path': '/webhooks/1/clientConfig/caBundle', 'value': \"${CA_BUNDLE}\" } \
  ]";
  {{- end }}
{{- end -}}
