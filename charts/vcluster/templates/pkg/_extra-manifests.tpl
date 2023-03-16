{{/* Generic CRDs
Sometimes it makes sense to install the crds so
that the dependency flow is easer in gitops

 */}}

{{/* Generic ServiceMonitor */}}
{{- define "pkg.manifests.servicemonitor-crd" -}}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-system
  namespace: {{ include "pkg.argo.ns" $ }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: "Cluster Apps"
  destinations:
  - name: "{{ $.Values.gitops.argocd.bootstrap.config.register.name }}"
    server: {{ include "pkg.argo.destination" $ }}
    namespace: '*'
  sourceRepos:
  - '*'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
{{- end -}}


{{/* Argo Manifests
Initial App to start synchronize cluster base-line
Expects following values:

    gitops:
      repository:
        url: "https://git.company.com/inventory.git"
        token: "token"
        ref: "init-branch"

For both Application and Repository Secret
*/}}

{{- define "pkg.manifests.argo-cluster-project" -}}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-system
  namespace: {{ include "pkg.argo.ns" $ }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: "Cluster Apps"
  destinations:
  - name: "{{ $.Values.gitops.argocd.bootstrap.config.register.name }}"
    server: {{ include "pkg.argo.destination" $ }}
    namespace: '*'
  sourceRepos:
  - '*'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
{{- end -}}

{{- define "pkg.manifests.argo-bootstrap-app" -}}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-system
  namespace: {{ include "pkg.argo.ns" $ }}
spec: {{- include "pkg.argo.app_commons" $ | nindent 2 }}
  project: "cluster-system"
  source:
    {{- with $.Values.gitops.repository }}
      {{- with .url }}
    repoURL: {{ . }}
      {{- end }}
    targetRevision: {{ default "initialize" .ref }}
    path: {{ include "pkg.utils.template" (dict "tpl" (default (printf "./clusters/%s" (include "pkg.cluster.name" $)) .path) "ctx" $) }}
    {{- end }}
    {{- with (include "gitops.substition.variables.env" $) }}
    plugin:
      env:
        {{- . | nindent 8 }}
    {{- end }}
  destination:
    server: {{ include "pkg.argo.destination" $ }}
    namespace: {{ include "pkg.argo.ns" $ }}
{{- end -}}

{{- define "pkg.manifests.argo-bootstrap-repository" -}}
apiVersion: v1
kind: Secret
metadata:
  name: bootstrap-repository
  namespace: {{ include "pkg.argo.ns" $ }}
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  {{- with $.Values.gitops.repository }}
  url: {{ .url }}
    {{- with .token }}
  password: {{ . }}
    {{- end }}
  username: "token"
  {{- end }}
{{- end -}}

{{- define "pkg.manifests.argo-app-ejson" -}}
  {{- if $.Values.gitops.ejson_key -}}
apiVersion: v1
kind: Secret
metadata:
  name: cluster-system
  namespace: {{ include "pkg.argo.ns" $ }}
stringData:
  private.key: {{ $.Values.gitops.ejson_key }}
  {{- end -}}
{{- end -}}