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
{{- define "overwrite" -}}
volumes:
  {{- if $.Values.e2g.config  }}
- name: "e2g-config"
  configMap:
    name: e2g-config
  {{- end }}
  {{- if $.Values.e2g.story  }}
- name: "e2g-story"
  configMap:
    name: e2g-story
  {{- end }}
  {{- if $.Values.e2g.lists  }}
- name: "e2g-lists"
  configMap:
    name: e2g-lists
  {{- end }}
  {{- if $.Values.e2g.filtergroups  }}
- name: "e2g-filtergroups"
  configMap:
    name: e2g-filtergroups
  {{- end }}
  {{ with $.Values.pod.volumes }}
    {{ toYaml . | nindent 0 }}
  {{- end }}
volumeMounts:
  {{ with $.Values.pod.volumeMounts }}
    {{ toYaml . | nindent 0 }}
  {{- end }}
  {{- with $.Values.e2g.story }}
    {{- range $i, $e := . }}
- mountPath: /usr/local/e2guardian/etc/e2guardian/{{ $i }}.story
  name: e2g-story
  subPath: {{ $i }}.story
      {{- end }}
  {{- end }}
  {{- with $.Values.e2g.lists }}
    {{- range $i, $e := . }}
- mountPath: /usr/local/e2guardian/etc/e2guardian/listen/{{ $i }}.list
  name: e2g-lists
  subPath: {{ $i }}.list
    {{- end }}
  {{- end }}
  {{- if $.Values.e2g.config }}
- mountPath: /usr/local/e2guardian/etc/e2guardian/e2guardian.conf
  name: e2g-config
  subPath: e2guardian.conf
  {{- end }}
  {{ with $.Values.e2g.filtergroups }}
    {{- range  . }}
- mountPath: /usr/local/e2guardian/etc/e2guardian/e2guardianf{{ .id }}.conf
  name: e2g-filtergroups
  subPath: e2guardianf{{ .id }}.conf
    {{- end }}
  {{- end }}
  {{- if or ($.Values.e2g.config) ($.Values.e2g.story)  ($.Values.e2g.lists) }}
podAnnotations:
  checksum/config: {{ tpl (toYaml .Values.e2g) . | sha256sum }}
  {{- end }}
{{- end -}}
