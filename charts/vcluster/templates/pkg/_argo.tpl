{{/*
    ArgoCD Templates (Current Cluster)
*/}}

{{/* Release Namespace */}}
{{- define "pkg.argo.release" -}}
{{ include "gitops.fullname" $ }}
{{- end -}}

{{/* Release Namespace */}}
{{- define "pkg.argo.release.namespace" -}}
  {{- if $.Values.gitops.argocd.incluster }}
    {{- printf "%s" "argocd" }}
  {{- else }}
    {{- printf "%s" $.Release.Namespace }}
  {{- end }}
{{- end -}}

{{/* Helm Values Secret Name */}}
{{- define "pkg.argo.release.values.secret" -}}
{{ include "gitops.fullname" $ }}-argocd-values
{{- end -}}


{{/* Installation Namespace */}}
{{- define "pkg.argo.ns" -}}
argocd
{{- end -}}


{{/*
    Argo Application Commons
*/}}
{{- define "pkg.argo.app_commons" -}}
# Sync policy
syncPolicy:
  automated: # automated sync by default retries failed attempts 5 times with following delays between attempts ( 5s, 10s, 20s, 40s, 80s ); retry controlled using `retry` field.
    prune: true # Specifies if resources should be pruned during auto-syncing ( false by default ).
    selfHeal: false # Specifies if partial app sync should be executed when resources are changed only in target Kubernetes cluster and no git change detected ( false by default ).
    allowEmpty: false # Allows deleting all application resources during automatic syncing ( false by default ).
  syncOptions:     # Sync options which modifies sync behavior
  - ServerSideApply=true # Enables server-side apply for kubectl apply ( false by default ).
  - Validate=false # disables resource validation (equivalent to 'kubectl apply --validate=false') ( true by default ).
  - CreateNamespace=true # Namespace Auto-Creation ensures that namespace specified as the application destination exists in the destination cluster.
  - PrunePropagationPolicy=foreground # Supported policies are background, foreground and orphan.
  - PruneLast=false # Allow the ability for resource pruning to happen as a final, implicit wave of a sync operation
  - ApplyOutOfSyncOnly=false # Only apply resources that are out of sync
  - FailOnSharedResource=true
  # The retry feature is available since v1.7
  retry:
    limit: -1 # number of failed sync attempt retries; unlimited number of attempts if less than 0
    backoff:
      duration: 30s # the amount to back off. Default unit is seconds, but could also be a duration (e.g. "2m", "1h")
      factor: 2 # a factor to multiply the base duration after each failed retry
      maxDuration: 3m # the maximum amount of time allowed for the backoff strategy
{{- end -}}


{{/*
  ArgoCD In-vCluster templates
*/}}

{{/* Release Namespace */}}
{{- define "pkg.argo.in_cluster.ns" -}}
{{- printf "%s" "argocd" -}}
{{- end -}}

{{/* Cluster Name */}}
{{- define "pkg.argo.destination" -}}
  {{- if (include "pkg.dev.incluster" $) }}
{{- include "pkg.cluster.endpoint.local" $ }}
  {{- else }}
{{- include "pkg.cluster.endpoint.internal" $ }}
  {{- end }}
{{- end -}}


{{/* Merge Default Values with given Values */}}
{{- define "pkg.argo.values" -}}
  {{- $values_raw := (include "pkg.argo.values.bootstrap" $) -}}
  {{- $values:= fromYaml ($values_raw) -}}
  {{- if (include "pkg.utils.unmarshalingError" $values) -}}
    {{- fail (printf "Values returned error '%s':\n%s" ($values.Error) ($values_raw | nindent 2)) -}}
  {{- end -}}

  {{- $base_values_raw := (include "pkg.argo.values.base" $) -}}
  {{- $base_values := fromYaml ($base_values_raw) -}}
  {{- if (include "pkg.utils.unmarshalingError" $base_values) -}}
    {{- fail (printf "Base Values returned error '%s':\n%s" ($base_values.Error) ($base_values_raw | nindent 2)) -}}
  {{- end -}}

  {{/* Merge */}}
  {{- toYaml (mergeOverwrite $base_values $values)| nindent 0 -}}

{{- end -}}

{{/* Evaluate Given Bootstrap Values */}}
{{- define "pkg.argo.values.bootstrap" -}}
  {{- $values := $.Values.gitops.argocd.bootstrap.values -}}
  {{- if eq (printf "%T" $values) "string" -}}
    {{- (tpl $values $) | nindent 0 -}}
  {{- else -}}
    {{- printf "%s" (tpl (toYaml $values) $) | nindent 0 -}}
  {{- end -}}
{{- end -}}

{{/*
    ArgoCD Application Values
      https://artifacthub.io/packages/helm/argo/argo-cd
*/}}
{{- define "pkg.argo.values.base" -}}
  {{- $argocd := $.Values.gitops.argocd -}}
{{- with (include "pkg.components.podSecurityContext" (dict "psc" $argocd.bootstrap.config.podSecurityContext "ctx" $)) }}
global:
  securityContext: {{ . | nindent 4 }}
{{- end }}

controller:
  {{- with (include "pkg.components.securityContext" (dict "sc" $argocd.bootstrap.config.securityContext "ctx" $)) }}
  containerSecurityContext: {{ . | nindent 4 }}
  {{- end }}
  env:
    {{- include "pkg.common.env" $ | nindent 4 }}
  serviceAccount:
    automountServiceAccountToken: true
  clusterAdminAccess:
    enabled: false
  extraArgs:
    {{- include "pkg.argo.connection-args" $ | nindent 4 }}
  volumes:
    {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
      {{- include "pkg.cluster.cp.vs" $ | nindent 4 }}
    {{- end }}
  volumeMounts:
    {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
      {{- include "pkg.cluster.cp.vms" $ | nindent 4 }}
    {{- end }}

server:
  {{- with (include "pkg.components.securityContext" (dict "sc" $argocd.bootstrap.config.securityContext "ctx" $)) }}
  containerSecurityContext: {{ . | nindent 4 }}
  {{- end }}
  env:
    {{- include "pkg.common.env" $ | nindent 4 }}
  serviceAccount:
    # Mount for InitContainer
    automountServiceAccountToken: true
  clusterAdminAccess:
    enabled: false
  {{- $ingress := $.Values.global.components.exposure.ingress }}
  extraArgs:
    {{- with $argocd.bootstrap.config.ingress }}
      {{- if.enabled }}
        {{- if .server.enabled }}
    - --insecure
          {{- with .server.contextPath }}
    - --rootpath={{ . }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- include "pkg.argo.connection-args" $ | nindent 4 }}
  volumes:
    {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
      {{- include "pkg.cluster.cp.vs" $ | nindent 4 }}
    {{- end }}
  volumeMounts:
    {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
      {{- include "pkg.cluster.cp.vms" $ | nindent 4 }}
    {{- end }}

  {{- with $argocd.bootstrap.config.ingress }}
    {{- if .enabled }}
      {{- if .server.enabled }}
  ingress:
    enabled: true
        {{- if or .annotations $ingress.annotations }}
    annotations:
          {{- with $ingress.annotations }}
            {{ toYaml . | indent 6 }}
          {{- end }}
          {{- with .annotations }}
            {{ toYaml . | indent 6 }}
          {{- end }}
        {{- end }}
        {{- if .ingressClassName }}
    ingressClassName: {{ .ingressClassName }}
        {{- else if $ingress.ingressClassName }}
    ingressClassName: {{ $ingress.ingressClassName }}
        {{- end }}
    hosts:
      - {{ include "pkg.components.ingress.host" $ }}
    paths:
      - {{ .server.contextPath }}
    tls:
      - hosts:
        - {{ include "pkg.components.ingress.host" $ }}
        secretName: {{ include "pkg.components.certificates.secretTlsName" $ }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- with $argocd.bootstrap.config.ingress }}
    {{- if .enabled  }}
      {{- if .grpc.enabled }}
  ingressGrpc:
    enabled: true
        {{- if or .annotations $ingress.annotations }}
    annotations:
          {{- with $ingress.annotations }}
            {{ toYaml . | indent 6 }}
          {{- end }}
          {{- with .annotations }}
            {{ toYaml . | indent 6 }}
          {{- end }}
        {{- end }}
        {{- if .ingressClassName }}
    ingressClassName: {{ .ingressClassName }}
        {{- else if $ingress.ingressClassName }}
    ingressClassName: {{ $ingress.ingressClassName }}
        {{- end }}
    hosts:
      - {{ include "pkg.components.ingress.host" $ }}
    paths:
      - {{ .grpc.contextPath }}
    tls:
      - hosts:
        - {{ include "pkg.components.ingress.host" $ }}
        secretName: {{ include "pkg.components.certificates.secretTlsName" $ }}
      {{- end }}
    {{- end }}
  {{- end }}

applicationSet:
  enabled: false
  {{- with (include "pkg.components.securityContext" (dict "sc" $argocd.bootstrap.config.securityContext "ctx" $)) }}
  containerSecurityContext: {{ . | nindent 4 }}
  {{- end }}
  env:
    {{- include "pkg.common.env" $ | nindent 4 }}
  serviceAccount:
    automountServiceAccountToken: true
  extraArgs:
    {{- include "pkg.argo.connection-args" $ | nindent 4 }}
  extraVolumes:
    {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
      {{- include "pkg.cluster.cp.vs" $ | nindent 4 }}
    {{- end }}
  extraVolumeMounts:
    {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
      {{- include "pkg.cluster.cp.vms" $ | nindent 4 }}
    {{- end }}

dex:
  {{- with (include "pkg.components.securityContext" (dict "sc" $argocd.bootstrap.config.securityContext "ctx" $)) }}
  containerSecurityContext: {{ . | nindent 4 }}
  {{- end }}
  env:
    {{- include "pkg.common.env" $ | nindent 4 }}
  serviceAccount:
    automountServiceAccountToken: true
  extraArgs:
    {{- include "pkg.argo.connection-args" $ | nindent 4 }}
  volumes:
    {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
      {{- include "pkg.cluster.cp.vs" $ | nindent 4 }}
    {{- end }}
  volumeMounts:
    {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
      {{- include "pkg.cluster.cp.vms" $ | nindent 4 }}
    {{- end }}

repoServer:
  {{- with (include "pkg.components.securityContext" (dict "sc" $argocd.bootstrap.config.securityContext "ctx" $)) }}
  containerSecurityContext: {{ . | nindent 4 }}
  {{- end }}
  serviceAccount:
    automountServiceAccountToken: true
  clusterAdminAccess:
    enabled: false
  env:
    {{- include "pkg.common.env" $ | nindent 2 }}
  volumes:
  {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
    {{- include "pkg.cluster.cp.vs" $ | nindent 2 }}
  {{- end }}
  {{- if (include "pkg.argo.plugin.subst.enabled" $) }}
  - emptyDir: {}
    name: subst-tmp
    {{- if (include "pkg.dev.incluster" $) }}
  - emptyDir: {}
    name: subst-kubeconfig
    {{- end }}
  {{- end }}

  initContainers:
    {{- if and (include "pkg.argo.plugin.subst.enabled" $) (include "pkg.dev.incluster" $) -}}
       {{- with $.Values.lifecycle.job }}
         {{- $image := dict "registry" "docker.io" "repository" "bash" "tag" "latest" "pullPolicy" "Always" }}
    - name: kubeconfig
      image: {{ include "pkg.images.registry.convert" (dict "image" $image "ctx" $) }}
      imagePullPolicy: {{ $image.pullPolicy }}
      command:
      - bash
      - -c
      - |
          TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
          CA=$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 | tr -d \\n)

          cat <<EOF > /tmp/admin.conf
          {{- include "pkg.kubeconfigs.kubeconfig.token" (dict "endpoint" (include "pkg.cluster.endpoint.local" $) "ctx" $) | nindent 10 }}
          EOF
      env: {{- include "pkg.common.env.w-proxy" $ | nindent 8 }}
      {{- include "pkg.utils.xdg-env" $ | nindent 8 }}
      {{- with (include "pkg.components.securityContext" (dict "sc" .securityContext "ctx" $)) }}
      securityContext: {{ . | nindent 8 }}
      {{- end }}
      {{- with .resources }}
      resources: {{ . | nindent 8 }}
      {{- end }}
      volumeMounts:
      - mountPath: /tmp/
        name: subst-kubeconfig
      {{- end }}
    {{- end }}

  extraContainers:
  {{- if (include "pkg.argo.plugin.subst.enabled" $) }}
    {{- with $argocd.bootstrap.plugins.subst }}
  - name: cmp-subst
    command: [/var/run/argocd/argocd-cmp-server]
    image: {{ include "pkg.images.registry.convert" (dict "image" .image "ctx" $) }}
    imagePullPolicy: {{ .image.pullPolicy }}
      {{- with (include "pkg.components.securityContext" (dict "sc" $argocd.bootstrap.config.securityContext "ctx" $)) }}
    securityContext: {{ . | nindent 10 }}
      {{- end }}
      {{- with .resources }}
    resources: {{ . | nindent 10 }}
      {{- end }}
    env:
      {{- include "pkg.common.env" $ | nindent 6 }}
    volumeMounts:
      {{- if or $argocd.bootstrap.config.automount_kubeconfig (not (include "pkg.dev.incluster" $)) }}
        {{- include "pkg.cluster.cp.vms" $ | nindent 6 }}
      {{- end }}
      - mountPath: /var/run/argocd
        name: var-files
      - mountPath: /home/argocd/cmp-server/plugins
        name: plugins
      # Starting with v2.4, do NOT mount the same tmp volume as the repo-server container. The filesystem separation helps
      # mitigate path traversal attacks.
      - mountPath: /tmp
        name: subst-tmp
      {{- if (include "pkg.dev.incluster" $) }}
      - mountPath: /etc/kubernetes/
        name: subst-kubeconfig
      {{- end }}
    {{- end }}
  {{- end }}
redis-ha:
  enabled: false
redis:
  enabled: true
  image:
    repository: redis
    tag: latest
    pullPolicy: IfNotPresent
{{- end -}}


{{/* Environment Variables for all Argo Components */}}
{{- define "pkg.argo.environment" -}}
  {{/* Default Environment Varibales */}}
  {{- with (include "pkg.common.env" $) -}}
    {{- . | nindent 0 }}
  {{- end -}}
  {{- if $.Values.gitops.argocd.bootstrap.config.inject_proxy }}
    {{- if (include "pkg.common.proxy.enabled" $) -}}
      {{- $no_proxy := include "pkg.common.proxy.no_proxy" $ -}}
      {{- range $host := (list "argocd-server" "argocd-repo-server" "argocd-redis" "argocd-applicationset-controller" "argocd-dex-server") -}}
        {{- $no_proxy = printf "%s,%s-%s" $no_proxy (include "pkg.argo.release" $) $host -}}
      {{- end -}}
      {{- with (include "pkg.common.proxy.host" $) }}
- name: "HTTP_RROXY"
  value: {{ . | quote }}
- name: "http_proxy"
  value: {{ . | quote }}
- name: "HTTPS_RROXY"
  value: {{ . | quote }}
- name: "https_proxy"
  value: {{ . | quote }}
      {{- end }}
      {{- with $no_proxy }}
- name: "NO_PROXY"
  value: {{ . | quote }}
- name: "no_proxy"
  value: {{ . | quote }}
      {{- end }}
    {{- end -}}
  {{- end }}
{{- end -}}


{{/* Server args for all Argo Components */}}
{{- define "pkg.argo.connection-args" -}}
  {{- $argocd := $.Values.gitops.argocd -}}
- --namespace={{ include "pkg.argo.ns" $ }}
  {{- if $argocd.bootstrap.config.automount_kubeconfig }}
- --certificate-authority=/pki/admin-client/ca.crt
- --client-certificate=/pki/admin-client/tls.crt
- --client-key=/pki/admin-client/tls.key
- --server={{ include "pkg.cluster.endpoint.internal" $ }}
  {{- end }}
{{- end -}}

{{- define "pkg.argo.template-cmd" -}}
  {{- $argocd := $.Values.gitops.argocd -}}
  {{- with $argocd.bootstrap -}}
helm template {{ include "pkg.argo.release" $ }} --namespace {{ include "pkg.argo.ns" $ }} argocd/{{ .chart }} {{ with .targetRevision }}--version {{ . }} {{ end }} -f /argocd/values.yaml
  {{- end -}}
{{- end -}}

{{- define "pkg.argo.plugin.subst.enabled" -}}
  {{- $manifest := $.Values.gitops.argocd -}}
  {{- if $manifest.enabled -}}
    {{- if $manifest.bootstrap.plugins.subst.enabled -}}
      {{- true -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
