{{/*
Component enabled
*/}}
{{- define "operating-system-manager.enabled" -}}
{{- $component := $.Values.osm -}}
  {{- if and $component.enabled (include "machine-controller.enabled" $) -}}
    {{- true -}}
  {{- end -}}
{{- end }}

{{/*
Component Manifests Configmap/Secret name
*/}}
{{- define "operating-system-manager.manifests.name" -}}
{{- printf "%s-manifests" (include "operating-system-manager.fullname" $) -}}
{{- end }}

{{/*
Component Manifests directory
*/}}
{{- define "operating-system-manager.manifests.dir" -}}
{{- printf "manifests/%s" (include "operating-system-manager.component" $) -}}
{{- end }}

{{/*
Component Manifests
*/}}
{{- define "operating-system-manager.manifests" -}}
{{- printf "%s/**.yaml" (include "operating-system-manager.manifests.dir" $) -}}
{{- end }}

{{/*
Component Webhook directory
*/}}
{{- define "operating-system-manager.webhooks.dir" -}}
{{- printf "webhooks/%s" (include "operating-system-manager.component" $) -}}
{{- end }}

{{/*
Component Webhook
*/}}
{{- define "operating-system-manager.webhooks" -}}
{{- printf "%s/**.yaml" (include "operating-system-manager.webhooks.dir" $) -}}
{{- end }}

{{/*
  Component
*/}}
{{- define "operating-system-manager.component" -}}
operating-system-manager
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "operating-system-manager.fullname" -}}
{{- $name := include "operating-system-manager.component" $ }}
{{- printf "%s-%s" (include "pkg.cluster.name" $) $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Base labels (Base)
*/}}
{{- define "operating-system-manager.labels" -}}
{{ include "pkg.common.labels" $ }}
{{ include "operating-system-manager.selectorLabels" $ }}
{{- end }}

{{/*
  Selector labels (Base)
*/}}
{{- define "operating-system-manager.selectorLabels" -}}
{{ include "pkg.common.labels.part-of" $ }}: {{ include "operating-system-manager.component" $ }}
{{ include "pkg.common.labels.component" $ }}: {{ include "operating-system-manager.component" $ }}
{{ include "pkg.common.selectors" $ }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "operating-system-manager.serviceAccountName" -}}
{{- $manifest := $.Values.osm -}}
{{- if $manifest.serviceAccount.create }}
{{- default (include "operating-system-manager.fullname" $) $manifest.serviceAccount.name }}
{{- else }}
{{- default "default" $manifest.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  Returns True if Admission Webhook is enabled
*/}}
{{- define "operating-system-manager.admission-enabled" -}}
  {{- if (include "operating-system-manager.enabled" $) -}}
    {{- $manifest := $.Values.osm -}}
    {{- if $manifest.admission.enabled -}}
      {{- true -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Create the Admission Webhook TLS Secret
*/}}
{{- define "operating-system-manager.secretTlsName" -}}
  {{- if (include "operating-system-manager.admission.expose.ingress" $) }}
{{- include "pkg.components.certificates.secretTlsName" $ -}}
  {{- else }}
{{- include "operating-system-manager.admission.secretTlsName" $ -}}
  {{- end }}
{{- end }}

{{/*
Self-Signed Admission Webhook TLS Secret
*/}}
{{- define "operating-system-manager.admission.secretTlsName" -}}
{{- $manifest := $.Values.osm -}}
{{ default ( printf "%s-tls" ( include "operating-system-manager.fullname" $) ) $manifest.admission.webhook.tls.name }}
{{- end -}}

{{/*
    Manifests Checksum
*/}}
{{- define "operating-system-manager.manifests.checksum" -}}
checksum/manifests: {{ (.Files.Glob (include "operating-system-manager.manifests" $) | toYaml | sha256sum | quote) }}
{{- end }}

{{/*
    Webhook Checksum
*/}}
{{- define "operating-system-manager.webhooks.checksum" -}}
checksum/webhooks: {{ (.Files.Glob (include "operating-system-manager.webhooks" $) | toYaml | sha256sum | quote) }}
{{- end }}

{{/*
    Common Controller Arguments
*/}}
{{- define "operating-system-manager.controller.args" -}}
- -kubeconfig={{ include "pkg.cluster.cp.env.mount" $ }}
  {{- if (include "pkg.common.proxy.enabled" $) }}
    {{- with (include "pkg.common.proxy.host" $) }}
- -node-http-proxy={{ . }}
      {{- with (include "pkg.common.proxy.no_proxy" $) }}
- -node-no-proxy={{ . | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if (include "pkg.images.registry.set" $) }}
    {{- if (include "pkg.images.registry.auth" $) }}
- -node-registry-credentials-secret={{ include "pkg.images.registry.secretnamespace" $ }}/regcreds
    {{- end }}
  {{- end }}
- -cluster-dns={{ include "kubernetes.getCoreDNS" $ }}
- -override-bootstrap-kubelet-apiserver={{ include "kubernetes.api.endpoint" $ }}
  {{- with $.Values.osm.kubelet.featureGates }}
- -node-kubelet-feature-gates={{ . | join "," | quote }}
  {{- end }}
{{- end -}}

{{/*
    Pause Image / OSM Compatible
*/}}
{{- define "operating-system-manager.pause" -}}
{{- $osm := $.Values.osm -}}
  {{- with $osm.pause }}
    {{- include "pkg.images.registry.convert" (dict "image" .image "ctx" $) -}}
  {{- end }}
{{- end }}

{{/*
    Runtime / OSM Compatible
*/}}
{{- define "operating-system-manager.runtime" -}}
{{- $osm := $.Values.osm -}}
  {{- with $osm.runtime }}
    {{- printf "%s" . -}}
  {{- end }}
{{- end }}

{{/*
Create the Admission Webhook Name
*/}}
{{- define "operating-system-manager.admission.webhook-name" -}}
operating-system-manager-webhook
{{- end -}}

{{/*
  Admission URL
*/}}
{{- define "operating-system-manager.admission.url" -}}

  {{/* If not enabled, use undefined in url (otherwise delete will fail) */}}
  {{- $base := "undefined" -}}

  {{- if (include "operating-system-manager.admission-enabled" $) -}}
    {{/* Expose via Ingress */}}
    {{- if (include "operating-system-manager.admission.expose.ingress" $) -}}
      {{- $base = (printf "https://%s/%s" (include "pkg.components.ingress.host" $) (include "operating-system-manager.admission.expose.ingress.context" $ | trimPrefix "/")) -}}
    {{- end -}}

    {{/* Expose via Service (LoadBalancer) */}}
    {{- if (include "operating-system-manager.admission.expose.loadbalancer" $) -}}
      {{- $base = (printf "https://%s:%s" (include "operating-system-manager.admission.expose.loadbalancer.ip" $) (include "operating-system-manager.admission.expose.loadbalancer.port" $)) -}}
    {{- end -}}
  {{- end -}}

  {{/* Print */}}
  {{- if $base -}}
    {{- (printf "%s" $base) | trimAll "/" -}}
  {{- end -}}
{{- end -}}

{{- define "operating-system-manager.admission.endpoint" -}}
  {{/* Expose via Ingress */}}
  {{- if (include "operating-system-manager.admission.expose.ingress" $) -}}
    {{- printf "%s" (include "pkg.components.ingress.host" $) -}}
  {{- else if (include "operating-system-manager.admission.expose.loadbalancer" $) -}}
    {{- printf "%s" (include "operating-system-manager.admission.expose.loadbalancer.ip" $) -}}
  {{- end -}}
{{- end -}}

{{/*
Admission Expose
*/}}
{{- define "operating-system-manager.admission.expose.loadbalancer" -}}
  {{- $manifest := $.Values.osm -}}
  {{- if not (include "operating-system-manager.admission.expose.ingress" $) -}}
    {{- if (eq (include "pkg.components.expose.type" (dict "expose" $manifest.admission.expose "ctx" $)) "loadbalancer") -}}
      {{- if (include "operating-system-manager.admission.expose.loadbalancer.ip" $) -}}
        {{- true -}}
      {{- else -}}
        {{- include "pkg.utils.fail" "LoadBalancerIP ($.Values.osm.admission.service.loadBalancerIP) must be defined for expose type loadbalancer" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "operating-system-manager.admission.expose.loadbalancer.ip" -}}
  {{- $manifest := $.Values.osm -}}
  {{- with $manifest.admission.service.loadBalancerIP -}}
    {{- printf "%s" . -}}
  {{- end -}}
{{- end -}}

{{- define "operating-system-manager.admission.expose.loadbalancer.port" -}}
  {{- $manifest := $.Values.osm -}}
  {{- with $manifest.admission.service.port -}}
    {{- . -}}
  {{- end -}}
{{- end -}}

{{- define "operating-system-manager.admission.expose.ingress" -}}
  {{- $manifest := $.Values.osm -}}
  {{- if or (eq $.Values.global.components.exposure.expose "ingress") (eq $manifest.admission.expose "ingress") -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{- define "operating-system-manager.admission.expose.ingress.context" -}}
  {{- $manifest := $.Values.osm -}}
  {{- printf "%s" (required "Context Required" $manifest.admission.ingress.contextPath) -}}
{{- end -}}

{{/* Volumes for Admission Pod */}}
{{- define "operating-system-manager.volumes" -}}
- name: osm-webhooks
  secret:
    defaultMode: 420
    secretName: {{ include "operating-system-manager.fullname" $ }}-webhooks
- name: osm-manifests
  secret:
    defaultMode: 420
    secretName: {{ include "operating-system-manager.manifests.name" $ }}
  {{- if (include "operating-system-manager.admission-enabled" $) }}
- name: osm-webhook-certs
  secret:
    defaultMode: 420
    secretName: {{ include "operating-system-manager.secretTlsName" $ }}
  {{- end }}
{{- end -}}

{{/* VolumeMounts for Admission Pod */}}
{{- define "operating-system-manager.volumemounts" -}}
- name: osm-webhooks
  mountPath: {{ include "operating-system-manager.volumemounts.webhooks.path" $}}
  readOnly: true
- name: osm-manifests
  mountPath: {{ include "operating-system-manager.volumemounts.manifests.path" $}}
  readOnly: true
  {{- include "operating-system-manager.volumemounts.certs" $ | nindent 0 }}
{{- end -}}

{{/* VolumeMounts for Admission Pod */}}
{{- define "operating-system-manager.volumemounts.certs" -}}
  {{- if (include "operating-system-manager.admission-enabled" $) }}
- mountPath: {{ include "operating-system-manager.volumemounts.certs.path" $ }}
  name: osm-webhook-certs
  readOnly: true
  {{- end }}
{{- end -}}

{{/* MountPath for certificates */}}
{{- define "operating-system-manager.volumemounts.certs.path" -}}
/tmp/osm/serving-certs/
{{- end -}}

{{/* MountPath for webhooks */}}
{{- define "operating-system-manager.volumemounts.webhooks.path" -}}
/tmp/osm/webhooks/
{{- end -}}

{{/* MountPath for Manifests */}}
{{- define "operating-system-manager.volumemounts.manifests.path" -}}
/tmp/osm/manifests/
{{- end -}}

{{/*
  Ensure All
*/}}
{{- define "operating-system-manager.ensure-resources" -}}
  {{- include "operating-system-manager.manifest-create" $ | nindent 0 }}
  {{- include "operating-system-manager.admission.webhook-cert-patch" $ | nindent 0 }}
{{- end -}}

{{/*
  Ensure Manifests
*/}}
{{- define "operating-system-manager.manifest-create" -}}
  {{- if (include "operating-system-manager.manifest-exist" $) -}}
if ! [ `find {{ include "operating-system-manager.volumemounts.manifests.path" $ }} -prune -empty 2>/dev/null` ]; then
    {{- if (include "operating-system-manager.enabled" $) }}
  # Apply operating-system-manager Manifests
  kubectl apply -f {{ include "operating-system-manager.volumemounts.manifests.path" $ }}
    {{- else }}
      {{- if $.Values.osm.component.removeManifestsOnDisable }}
  # Delete operating-system-manager Manifests
  kubectl delete -f {{ include "operating-system-manager.volumemounts.manifests.path" $ }} 2>/dev/null || true
      {{- end }}
    {{- end }}
fi
  {{- end -}}
{{- end -}}

{{/*
 Validate if any Manifests are rendered
*/}}
{{- define "operating-system-manager.manifest-exist" -}}
  {{- $files := .Files.Glob (include "operating-system-manager.manifests" $) -}}
  {{- if $files -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/*
  InitContainer to apply/delete manifests
*/}}
{{- define "operating-system-manager.manifest-init" -}}
  {{- $manifest := $.manifest -}}
  {{- if (include "operating-system-manager.manifest-exist" $.ctx) }}
- name: osm-manifests
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
    - /bin/sh
    - -c
    - |
        {{- include "operating-system-manager.ensure-resources" $.ctx | nindent 8 }}
  volumeMounts: {{- include "pkg.cluster.cp.vms" $.ctx | nindent 4 }}
    {{- include "operating-system-manager.volumemounts" $.ctx | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
  Ensure Webhooks
*/}}
{{- define "operating-system-manager.admission.webhook-cert-patch" -}}
  {{- if not (include "operating-system-manager.admission-enabled" $) }}
# Remove Webhooks (Be explicit, since content may have changed)
kubectl delete validatingwebhookconfiguration {{ include "operating-system-manager.admission.webhook-name" $ }} 2>/dev/null || true
kubectl delete mutatingwebhookconfiguration {{ include "operating-system-manager.admission.webhook-name" $ }} 2>/dev/null || true
  {{- else }}

# Ensure Webhooks are present
kubectl apply -f {{ include "operating-system-manager.volumemounts.webhooks.path" $ }}

# Export the CA bundle to a file (Must be single line)
export CA_BUNDLE=`openssl base64 -in {{ include "operating-system-manager.volumemounts.certs.path" $ }}tls.crt | tr -d '\n'`;

# Patch the CA bundle in the webhook configurations
kubectl patch ValidatingWebhookConfiguration {{ include "operating-system-manager.admission.webhook-name" $ }} \
  --type='json' -p="[\
  	{'op': 'replace', 'path': '/webhooks/0/clientConfig/caBundle', 'value': \"${CA_BUNDLE}\" },\
    {'op': 'replace', 'path': '/webhooks/1/clientConfig/caBundle', 'value': \"${CA_BUNDLE}\" } \
  ]";
kubectl patch MutatingWebhookConfiguration {{ include "operating-system-manager.admission.webhook-name" $ }} \
  --type='json' -p="[\
  	{'op': 'replace', 'path': '/webhooks/0/clientConfig/caBundle', 'value': \"${CA_BUNDLE}\" }\
  ]";
  {{- end }}
{{- end -}}
