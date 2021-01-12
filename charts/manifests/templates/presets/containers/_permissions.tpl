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
  Preset - Template Inclusion
*/}}
{{- define "bedag-lib.presets.permissions" -}}
  {{- if and .values .context }}
    {{- if .values.enabled }}
      {{- $_ := set . "container" .values }}
{{- include "bedag-lib.template.container" . }}
      {{- $_ := unset . "container" }}
    {{- end }}
  {{- else }}
    {{- fail "Module requires '.module' and '.context' in the key structure" }}
  {{- end }}
{{- end -}}

{{/*
  Preset - Overwrite Values
*/}}
{{- define "bedag-lib.presets.permissions.overwrites" -}}
containerName: {{ default "permissions" .name }}
command:
  - /bin/bash
args:
  - -ec
  - |
    chown -R {{ default "0" .values.runAsUser }}:{{ default "0" .values.runAsGroup }} {{ .values.directories | join " " }}
        {{- if .values.mode }}
    chmod -R {{ .values.mode }} {{ .values.directories | join " " }}
        {{- end }}
securityContext:
  runAsUser: 0
{{- end }}
