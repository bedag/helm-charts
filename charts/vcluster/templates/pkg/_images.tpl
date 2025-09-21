{{/*
    Docker Registry Endpoint
*/}}
{{- define "pkg.images.registry.url" -}}
  {{- if (include "pkg.images.registry.set" $) -}}
    {{- $url := $.Values.global.registries.primary.endpoint -}}
    {{- printf "%s" ($url | trimAll "/") -}}
  {{- end -}}
{{- end -}}

{{/*
    Docker Registry Set
*/}}
{{- define "pkg.images.registry.set" -}}
{{- $url := $.Values.global.registries.primary.endpoint -}}
  {{- if $url -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/*
    Docker Credentials Set
*/}}
{{- define "pkg.images.registry.auth" -}}
{{- $registry := $.Values.global.registries -}}
  {{- if and ($registry.primary.creds.username) ($registry.primary.creds.password) -}}
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
  {{- $auths := list }}

  {{- if and (include "pkg.images.registry.set" $) (include "pkg.images.registry.auth" $) -}}
    {{- $registry := $.Values.global.registries.primary -}}
    {{- $url := include "pkg.images.registry.url" $ }}
    {{- $auth := printf "\"%s\":{\"auth\":\"%s\"}" $url (printf "%s:%s" $registry.creds.username $registry.creds.password | b64enc) }}
    {{- $auths = append $auths $auth }}
  {{- end }}

  {{- range $url, $cfg := $.Values.global.registries.secondaries }}
    {{- if and $cfg.creds.username $cfg.creds.password }}
      {{- $auth := printf "\"%s\":{\"auth\":\"%s\"}" $url (printf "%s:%s" $cfg.creds.username $cfg.creds.password | b64enc) }}
      {{- $auths = append $auths $auth }}
    {{- end }}
  {{- end }}

  {{- if $auths }}
    {{- printf "{\"auths\":{%s}}" (join "," $auths) | b64enc }}
  {{- end }}
{{- end -}}

{{/* PullSecret for Registry */}}
{{- define "pkg.images.registry.pullsecrets" -}}
  {{- $components := $.Values.global.components -}}
  {{- if (include "pkg.images.registry.auth" $) }}
- name: {{ template "pkg.images.registry.secretname" $ }}
  {{- end }}
  {{- if $components.workloads.image.pullSecrets }}
    {{- toYaml $components.workloads.image.pullSecrets | nindent 0 }}
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
