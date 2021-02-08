{{/*

Copyright © 2021 Bedag Informatik AG

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}
{{/*
  Kafdrop Configuration
  Renders Broker Connections correctly, if they are type slice, Handles the default, when it's already a single string
*/}}
{{- define "kafdrop.connections" -}}
    {{- $connections := $.Values.config.kafka.connections -}}
    {{- if kindIs "slice" $.Values.config.kafka.connections }}
        {{- $connections = ($.Values.config.kafka.connections | join ", ") -}}
    {{- end }}
    {{- printf "%s" $connections -}}
{{- end }}

{{/*
  Kafdrop Configuration
  Renders Broker Connections correctly, if they are type slice, Handles the default, when it's already a single string
*/}}
{{- define "kafdrop.jvmopts" -}}
    {{- $jvmopts := $.Values.config.jvm -}}
    {{- if kindIs "slice" $.Values.config.jvm }}
        {{- $jvmopts = ($.Values.config.jvm | join " ") -}}
    {{- end }}
    {{- printf "%s" $jvmopts -}}
{{- end -}}

{{/*
  Kafdrop Configuration Merges Commandline Arguments with Protocol Path, if defined
*/}}
{{- define "kafdrop.protobuf" -}}
{{- if $.Values.config.protoDesc.enabled -}} --message.format=PROTOBUF --protobufdesc.directory={{- $.Values.config.protoDesc.path -}} {{- end -}}
{{- end -}}

{{/*
  Kafdrop Configuration
  Merges Commandline Arguments with Protocol Path, if defined
*/}}
{{- define "kafdrop.cmdArgs" -}}
    {{- if $.Values.config.cmdArgs }}
        {{- $args := $.Values.config.cmdArgs -}}
        {{- if kindIs "slice" $.Values.config.cmdArgs }}
            {{- $args = ($.Values.config.cmdArgs| join " ") -}}
        {{- end }}
        {{- printf "%s %s" $args (include "kafdrop.protobuf" .) -}}
    {{- end }}
{{- end -}}

{{- define "kafdrop.endpoint" }}
{{- $.Values.config.server.context | trimSuffix "/" | nospace }}/actuator/health
{{- end }}


{{/*
  Kafdrop Environment Configuration
*/}}
{{- define "kafdrop.configuration" -}}
- name: KAFKA_BROKERCONNECT
  value: "{{ template "kafdrop.connections" . }}"
- name: JVM_OPTS
  value: "{{ template "kafdrop.jvmopts" . }}"
- name: SERVER_SERVLET_CONTEXT_PATH
  value: "{{ $.Values.config.server.context }}"
- name: SERVER_PORT
  value: "{{ $.Values.config.server.port }}"
- name: CMD_ARGS
  value: "{{ template "kafdrop.cmdArgs" . }}"
  {{- if $.Values.config.kafka.properties.content }}
- name: KAFKA_PROPERTIES
  secret: true
  value: {{ include "lib.utils.strings.template" (dict "value" .Values.config.kafka.properties.content "context" $) }}
  {{- end }}
- name: KAFKA_PROPERTIES_FILE
  value: "{{ $.Values.config.kafka.properties.destination }}"
  {{- if $.Values.config.kafka.truststore.content }}
- name: KAFKA_TRUSTSTORE
  secret: true
  value: {{ include "lib.utils.strings.template" (dict "value" .Values.config.kafka.truststore.content "context" $) }}
  {{- end }}
- name: KAFKA_TRUSTSTORE_FILE
  value: "{{ $.Values.config.kafka.truststore.destination }}"
  {{- if $.Values.config.kafka.keystore.content }}
- name: KAFKA_KEYSTORE
  secret: true
  value: {{ include "lib.utils.strings.template" (dict "value" .Values.config.kafka.keystore.content "context" $) }}
  {{- end }}
- name: KAFKA_KEYSTORE_FILE
  value: "{{ $.Values.config.kafka.keystore.destination }}"
  {{- if $.Values.jmxExporter.enabled }}
- name: JMX_PORT
  value: "{{ $.Values.jmxExporter.targetPort }}"
  {{- end }}
{{- end -}}
