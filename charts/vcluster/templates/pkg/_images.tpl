{{/*
    Docker Registry Endpoint
*/}}
{{- define "pkg.images.registry.url" -}}
  {{- if (include "pkg.images.registry.set" $) -}}
    {{- $url := $.Values.global.registry.endpoint -}}
    {{- printf "%s" ($url | trimAll "/") -}}
  {{- end -}}
{{- end -}}

{{/*
    Docker Registry Set
*/}}
{{- define "pkg.images.registry.set" -}}
{{- $url := $.Values.global.registry.endpoint -}}
  {{- if $url -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/*
    Docker Credentials Set
*/}}
{{- define "pkg.images.registry.auth" -}}
{{- $registry := $.Values.global.registry -}}
  {{- if and ($registry.creds.username) ($registry.creds.password) -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/*
    Docker Credentials Secret Name
*/}}
{{- define "pkg.images.registry.secretname" -}}
{{- printf "%s-%s" (include "pkg.cluster.name" $) "regcred" -}}
{{- end -}}

{{/*
    Docker Credentials Secret Namespace
      Must be kube-system, so system-crtical pods can access it
*/}}
{{- define "pkg.images.registry.secretnamespace" -}}
kube-system
{{- end -}}

{{/*
    Docker Credentials (DockerConfigJSON)
*/}}
{{- define "pkg.images.dockerconfigjson" -}}
  {{- if and (include "pkg.images.registry.set" $) (include "pkg.images.registry.auth" $) -}}
    {{- $registry := $.Values.global.registry -}}
    {{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" (include "pkg.images.registry.url" $) $registry.creds.username $registry.creds.password (default "" $registry.creds.email) (printf "%s:%s" .username .password | b64enc) | b64enc }}
  {{- end -}}
{{- end -}}

{{/* PullSecret for Registry */}}
{{- define "pkg.images.registry.pullsecrets" -}}
  {{- $components := $.Values.global.components -}}
  {{- if (include "pkg.images.registry.auth" $) }}
- name: {{ template "pkg.images.registry.secretname" $ }}
  {{- end }}
  {{- if $components.workloads.image.pullsecrets }}
     {{- toYaml $components.workloads.image.pullsecrets | nindent 0 }}
  {{- end }}
{{- end -}}


{{/* PullPolicy */}}
{{- define "pkg.images.registry.pullpolicy" -}}
  {{- $components := $.ctx.Values.global.components -}}
  {{- $policy := $.policy -}}
  {{- if $components.workloads.image.pullPolicy -}}
    {{- $policy = $components.workloads.image.pullPolicy -}}
  {{- end -}}
  {{- if $policy -}}
    {{ printf "%s" $policy }}
  {{- end -}}
{{- end -}}


{{/*
    Prepend Registry URL to Image

    This function prepends the registry URL to the image name, if the registry URL is set.

    args:
        image: <map>
          registry: image registry
          repository: image repository
          tag: image tag
          digest: image digest
        tag_overwrite: (optional) override the image tag (if image.tag is not set)
        ctx: Global Context
*/}}
{{- define "pkg.images.registry.convert" -}}
  {{- $image_registry := $.image.registry -}}
  {{- $image_repository := $.image.repository -}}
  {{- $termination := $.image.tag | toString -}}
  {{- $separator := ":" -}}
  {{- if (include "pkg.images.registry.set" $.ctx) -}}
      {{- $image_registry = include "pkg.images.registry.url" $.ctx -}}
  {{- end -}}
  {{- if $.image.digest -}}
      {{- $separator = "@" -}}
      {{- $termination = $.image.digest | toString -}}
  {{- end -}}
  {{- if and (not $termination) $.tag_overwrite -}}
    {{- $termination = $.tag_overwrite | toString -}}
  {{- end -}}
  {{- printf "%s/%s%s%s" $image_registry $image_repository $separator $termination -}}
{{- end -}}
