{{/*
Component enabled
*/}}
{{- define "kubernetes.enabled" -}}
{{- $component := $.Values.kubernetes -}}
  {{- if $component.enabled -}}
    {{- true -}}
  {{- end -}}
{{- end }}

{{/*
Component Manifests directory
*/}}
{{- define "kubernetes.manifests.dir" -}}
{{- printf "manifests/%s/" (include "kubernetes.component" $) -}}
{{- end }}

{{/*
Component Manifests
*/}}
{{- define "kubernetes.manifests" -}}
{{- printf "%s/**.yaml" (include "kubernetes.manifests.dir" $) -}}
{{- end }}


{{/*
  Component Name
*/}}
{{- define "kubernetes.component" -}}
kubernetes
{{- end }}


{{/*
Expand the name of the chart.
*/}}
{{- define "kubernetes.name" -}}
{{- include "kubernetes.component" $ -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "kubernetes.fullname" -}}
{{- $name := include "kubernetes.name" $ }}
{{- printf "%s-%s" (include "pkg.cluster.name" $) $name | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
  Base labels (Base)
*/}}
{{- define "kubernetes.labels" -}}
{{ include "pkg.common.labels" $ }}
{{ include "kubernetes.selectorLabels" $ }}
{{- end }}

{{/*
  Selector labels (Base)
*/}}
{{- define "kubernetes.selectorLabels" -}}
{{ include "pkg.common.labels.part-of" $ }}: {{ include "kubernetes.component" $ }}
{{ include "pkg.common.selectors" $ }}
{{- end }}



{{/*
Create a default certificate name.
*/}}
{{- define "kubernetes.certname" -}}
{{- $kubernetes := $.Values.kubernetes -}}
{{- if $kubernetes.certnameOverride -}}
{{- $kubernetes.certnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- template "kubernetes.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Generate etcd servers list.
*/}}
{{- define "kubernetes.etcdEndpoints" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
  {{- $fullName := include "kubernetes.fullname" . -}}
  {{- range $etcdcount, $e := until (int $kubernetes.etcd.replicaCount) -}}
    {{- printf "https://" -}}
    {{- printf "%s-etcd-%d." $fullName $etcdcount -}}
    {{- printf "%s-etcd:%d" $fullName (int $kubernetes.etcd.ports.client) -}}
    {{- if lt $etcdcount (sub (int $kubernetes.etcd.replicaCount) 1 ) -}}
      {{- printf "," -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "kubernetes.etcdInitialCluster" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
  {{- $fullName := include "kubernetes.fullname" . -}}
  {{- range $etcdcount, $e := until (int $kubernetes.etcd.replicaCount) -}}
    {{- printf "%s-etcd-%d=" $fullName $etcdcount -}}
    {{- printf "https://" -}}
    {{- printf "%s-etcd-%d." $fullName $etcdcount -}}
    {{- printf "%s-etcd:%d" $fullName (int $kubernetes.etcd.ports.peer) -}}
    {{- if lt $etcdcount (sub (int $kubernetes.etcd.replicaCount) 1 ) -}}
      {{- printf "," -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Take the first IP address from the serviceSubnet for the kube-dns service.
*/}}
{{- define "kubernetes.getCoreDNS" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
  {{- $octetsList := splitList "." $kubernetes.networking.serviceSubnet -}}
  {{- printf "%d.%d.%d.%d" (index $octetsList 0 | int) (index $octetsList 1 | int) (index $octetsList 2 | int) 10 -}}
{{- end -}}

{{- define "kubernetes.getAPIAddress" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
  {{- $octetsList := splitList "." $kubernetes.networking.serviceSubnet -}}
  {{- printf "%d.%d.%d.%d" (index $octetsList 0 | int) (index $octetsList 1 | int) (index $octetsList 2 | int) 1 -}}
{{- end -}}

{{/*
Template for konnectivityServer containers
*/}}
{{- define "kubernetes.konnectivityServer.containers" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
      - command:
        - /proxy-server
        - --logtostderr=true
        - --server-count={{ $kubernetes.konnectivityServer.replicaCount }}
        - --server-id=$(POD_NAME)
        - --cluster-cert=/pki/apiserver/tls.crt
        - --cluster-key=/pki/apiserver/tls.key
        {{- if eq $kubernetes.konnectivityServer.mode "HTTPConnect" }}
        - --mode=http-connect
        - --server-port={{ $kubernetes.konnectivityServer.ports.server }}
        - --server-ca-cert=/pki/konnectivity-server/ca.crt
        - --server-cert=/pki/konnectivity-server/tls.crt
        - --server-key=/pki/konnectivity-server/tls.key
        {{- else }}
        - --mode=grpc
        - --uds-name=/run/konnectivity-server/konnectivity-server.socket
        - --server-port=0
        {{- end }}
        - --agent-port={{ $kubernetes.konnectivityServer.ports.agent }}
        - --admin-port={{ $kubernetes.konnectivityServer.ports.admin }}
        - --health-port={{ $kubernetes.konnectivityServer.ports.health }}
        - --agent-namespace=kube-system
        - --agent-service-account=konnectivity-agent
        - --kubeconfig=/etc/kubernetes/konnectivity-server.conf
        - --authentication-audience=system:konnectivity-server
        {{- with $kubernetes.konnectivityServer.extraArgs }}
          {{- include "pkg.utils.args" (dict "args" . "ctx" $) | nindent 8 }}
        {{- end }}
        ports:
        {{- if eq $kubernetes.konnectivityServer.mode "HTTPConnect" }}
        - containerPort: {{ $kubernetes.konnectivityServer.ports.server }}
          name: server
        {{- end }}
        - containerPort: {{ $kubernetes.konnectivityServer.ports.agent }}
          name: agent
        - containerPort: {{ $kubernetes.konnectivityServer.ports.admin }}
          name: admin
        - containerPort: {{ $kubernetes.konnectivityServer.ports.health }}
          name: health
        {{- with $kubernetes.konnectivityServer.image }}
        image: {{ include "pkg.images.registry.convert" (dict "image" . "ctx" $) }}
        imagePullPolicy: {{ include "pkg.images.registry.pullpolicy" (dict "policy" .pullPolicy "ctx" $) }}
        {{- end }}
        livenessProbe:
          failureThreshold: 8
          httpGet:
            path: /healthz
            port: {{ $kubernetes.konnectivityServer.ports.health }}
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 60
        name: konnectivity-server
        resources:
          {{- toYaml $kubernetes.konnectivityServer.resources | nindent 10 }}
        {{- if $kubernetes.konnectivityServer.securityContext.enabled }}
          {{- with $kubernetes.konnectivityServer.securityContext }}
        securityContext:
          {{- toYaml (omit . "enabled") | nindent 10 }}
          {{- end }}
        {{- end }}
        {{- with $kubernetes.konnectivityServer.envsFrom }}
        envFrom:
          {{- toYaml . | nindent 8 }}
        {{- end }}
        env: {{- include "pkg.common.env" $ | nindent 8 }}
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        {{- with $kubernetes.konnectivityServer.envs }}
          {{- include "pkg.utils.envs" (dict "envs" . "ctx" $) | nindent 8 }}
        {{- end }}
        volumeMounts:
        - mountPath: /pki/apiserver
          name: pki-apiserver
        {{- if eq $kubernetes.konnectivityServer.mode "HTTPConnect" }}
        - mountPath: /pki/konnectivity-server
          name: pki-konnectivity-server
        {{- else }}
        - mountPath: /run/konnectivity-server
          name: konnectivity-uds
        {{- end }}
        - mountPath: /pki/konnectivity-server-client
          name: pki-konnectivity-server-client
        - mountPath: /etc/kubernetes/
          name: kubeconfig
          readOnly: true
        {{- with $kubernetes.konnectivityServer.extraVolumeMounts }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
{{- end -}}

{{/*
Template for konnectivityServer volumes
*/}}
{{- define "kubernetes.konnectivityServer.volumes" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
      - secret:
          secretName: "{{ template "kubernetes.fullname" . }}-pki-apiserver-server"
        name: pki-apiserver
      {{- if eq $kubernetes.konnectivityServer.mode "HTTPConnect" }}
      - secret:
          secretName: "{{ template "kubernetes.fullname" . }}-pki-konnectivity-server"
        name: pki-konnectivity-server
      {{- else }}
      - secret:
          secretName: "{{ template "kubernetes.fullname" . }}-pki-konnectivity-server-client"
        name: pki-konnectivity-server-client
      - emptyDir: {}
        name: konnectivity-uds
      {{- end }}
      - configMap:
          name: "{{ template "kubernetes.fullname" . }}-konnectivity-server-conf"
        name: kubeconfig
      {{- with $kubernetes.konnectivityServer.extraVolumes }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
{{- end -}}


{{/*
Template for API Server
*/}}
{{- define "kubernetes.api.url" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
  {{- with $kubernetes.apiServer.service.port -}}
    {{- printf "https://%s:%s" (include "kubernetes.api.service" $) (. | toString) -}}
  {{- end -}}
{{- end -}}

{{/*
Template API Server Service
*/}}
{{- define "kubernetes.api.service" -}}
  {{- $fullName := include "kubernetes.fullname" . -}}
  {{- printf "%s-apiserver" ($fullName) -}}
{{- end -}}

{{/*
Template for Endpoint
*/}}
{{- define "kubernetes.api.endpoint" -}}
  {{- printf "https://%s:%s" (include "kubernetes.api.endpointIP" $) (include "kubernetes.api.endpointPort" $) -}}
{{- end -}}


{{/*
Template for Endpoint IP
*/}}
{{- define "kubernetes.api.endpointIP" -}}
  {{- $host := "" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
  {{- with $kubernetes.controlPlane -}}
    {{- if .endpoint -}}
      {{- with (regexFind (include "pkg.utils.regex.ip" $) .endpoint) -}}
        {{- $host = . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s" $host -}}
{{- end -}}

{{/*
Template for Endpoint port
*/}}
{{- define "kubernetes.api.endpointPort" -}}
  {{- $port := "6443" -}}
  {{- $kubernetes := $.Values.kubernetes -}}
  {{- with $kubernetes.controlPlane -}}
    {{- if .endpoint -}}
      {{- $sp := split ":" .endpoint -}}
      {{- with $sp._1 -}}
        {{- if (regexMatch (include "pkg.utils.regex.port" $) .) -}}
          {{- $port = . -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s" $port -}}
{{- end -}}
