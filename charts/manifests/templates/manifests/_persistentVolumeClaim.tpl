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
{{- define "bedag-lib.manifest.persistentvolumeclaim.values" -}}
  {{- include "lib.utils.strings.template" (dict "value" (include "bedag-lib.utils.common.mergedValues" (dict "type" "persistentvolumeclaim" "key" "pvc" "root" .)) "context" .context) -}}
{{- end }}

{{- define "bedag-lib.manifest.persistentvolumeclaim" -}}
  {{- if .context -}}
    {{- $context := .context -}}
    {{- $pvc := (fromYaml (include "bedag-lib.manifest.persistentvolumeclaim.values" .)) -}}
    {{- if $pvc.enabled -}}
kind: PersistentVolumeClaim
      {{- if $pvc.apiVersion }}
apiVersion: {{ $pvc.apiVersion }}
      {{- else }}
apiVersion: v1
      {{- end }}
      {{- include "bedag-lib.template.persistentVolumeClaim" (set . "pvc" $pvc) | nindent 0 }}
    {{- end }}
  {{- else }}
    {{- fail "Template requires '.context' as arguments" }}
  {{- end }}
{{- end }}
