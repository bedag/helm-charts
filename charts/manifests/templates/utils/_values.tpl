/*

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

*/
{{- define "bedag-lib.utils.values.generator" -}}
  {{- if $.Values }}
    {{- if $.Values.doc }}
      {{- if or $.Values.doc.manifest $.Values.doc.preset }}
        {{- $context := $ }}
        {{- $resource := "" }}
        {{- if $.Values.doc.manifest }}
          {{- $resource = cat "bedag-lib.values." ($.Values.doc.manifest | lower) | nospace }}
        {{- else }}
          {{- $resource = cat "bedag-lib.presets.values." ($.Values.doc.preset | lower) | nospace }}
        {{- end }}
        {{- $path :=  (default "" $.Values.doc.path) }}
        {{- if not (hasSuffix "." $path) }}
          {{- $path = (cat $path "." | nospace) }}
        {{- end }}
        {{- if (eq "." $path) }}
          {{- $path = "" }}
        {{- end }}
        {{- $params := dict "path" $path "key" (default "" $.Values.doc.key) "context" $context "minimal" (default false $.Values.doc.minimal) }}
        {{- if $path }}
          {{- include "lib.utils.dicts.printYAMLStructure" (dict "structure" $path "data" (include $resource $params)) | nindent 0 }}
        {{- else }}
          {{- include $resource $params | nindent 0 }}
        {{- end }}
      {{- else }}
        {{- include "lib.values.all" $ | nindent 0 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
