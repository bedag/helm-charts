{{/*
    Components Workload Labels
*/}}
{{- define "pkg.components.labels" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $labels := $.labels -}}
  {{- with $components.workloads.labels -}}
    {{- $labels = mergeOverwrite $labels . -}}
  {{- end -}}
  {{- if $labels -}}
    {{- printf "%s" (toYaml $labels) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Pod Labels
*/}}
{{- define "pkg.components.pod_labels" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $labels := $.labels -}}
  {{- with $components.workloads.podLabels -}}
    {{- $labels = mergeOverwrite $labels . -}}
  {{- end -}}
  {{- if $labels -}}
    {{- printf "%s" (toYaml $labels) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Workload Annotations
*/}}
{{- define "pkg.components.annotations" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $annotations := $.annotations -}}
  {{- with $components.workloads.annotations -}}
    {{- $annotations = mergeOverwrite $annotations . -}}
  {{- end -}}
  {{- if $annotations -}}
    {{- printf "%s" (toYaml $annotations) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Pod Annotations
*/}}
{{- define "pkg.components.pod_annotations" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $annotations := $.annotations -}}
  {{- with $components.workloads.podAnnotations -}}
    {{- $annotations = mergeOverwrite $annotations . -}}
  {{- end -}}
  {{- if $annotations -}}
    {{- printf "%s" (toYaml $annotations) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Service Annotations
*/}}
{{- define "pkg.components.svc_annotations" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $annotations := $.annotations -}}
  {{- with $components.svcAnnotations -}}
    {{- $annotations = mergeOverwrite $annotations . -}}
  {{- end -}}
  {{- if $annotations -}}
    {{- printf "%s" (toYaml $annotations) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Service Labels
*/}}
{{- define "pkg.components.svc_labels" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $labels := $.labels -}}
  {{- with $components.svcLabels -}}
    {{- $labels = mergeOverwrite $labels . -}}
  {{- end -}}
  {{- if $labels -}}
    {{- printf "%s" (toYaml $labels) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Affinity
*/}}
{{- define "pkg.components.affinity" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $affinity := $.affinity -}}
  {{- if $components.workloads.affinity -}}
    {{- $affinity = $components.workloads.affinity -}}
  {{- end -}}
  {{- if $affinity -}}
    {{- printf "%s" (toYaml $affinity) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components tolerations
*/}}
{{- define "pkg.components.tolerations" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $tolerations := $.tolerations -}}
  {{- if $components.workloads.tolerations -}}
    {{- $tolerations = $components.workloads.tolerations -}}
  {{- end -}}
  {{- if $tolerations -}}
    {{- printf "%s" (toYaml $tolerations) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Nodeselector
*/}}
{{- define "pkg.components.nodeselector" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $nodeselector := $.nodeSelector -}}
  {{- if $components.workloads.nodeSelector -}}
    {{- $nodeselector = $components.workloads.nodeSelector -}}
  {{- end -}}
  {{- if $nodeselector -}}
    {{- printf "%s" (toYaml $nodeselector) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components TopologySpreadConstraint
*/}}
{{- define "pkg.components.topologySpreadConstraints" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $topologySpreadConstraints := $.tsc -}}
  {{- if $components.workloads.topologySpreadConstraints -}}
    {{- $topologySpreadConstraints = $components.workloads.topologySpreadConstraints -}}
  {{- end -}}
  {{- if $topologySpreadConstraints -}}
    {{- printf "%s" (toYaml $topologySpreadConstraints) -}}
  {{- end -}}
{{- end -}}


{{/*
    Components Priority Class
*/}}
{{- define "pkg.components.priorityClass" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $class := $.pc -}}
  {{- if $components.workloads.priorityClassName -}}
    {{- $class = $components.workloads.priorityClassName -}}
  {{- end -}}
  {{- if $class -}}
    {{- printf "%s" $class -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Pod Security Context
*/}}
{{- define "pkg.components.podSecurityContext" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $psc := $.psc -}}
  {{- if $components.workloads.podSecurityContext -}}
    {{- $psc = $components.workloads.podSecurityContext -}}
  {{- end -}}
  {{- if $psc.enabled -}}
    {{- printf "%s" (toYaml (omit $psc "enabled")) -}}
  {{- end -}}
{{- end -}}

{{/*
    Components Security Context
*/}}
{{- define "pkg.components.securityContext" -}}
  {{- $components := $.ctx.Values.components -}}
  {{- $sc := $.sc -}}
  {{- if $components.workloads.securityContext -}}
    {{- $sc = $components.workloads.securityContext -}}
  {{- end -}}
  {{- if $sc.enabled -}}
    {{- printf "%s" (toYaml (omit $sc "enabled")) -}}
  {{- end -}}
{{- end -}}
