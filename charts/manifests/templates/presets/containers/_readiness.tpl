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
{{- define "bedag-lib.presets.readiness" -}}
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
{{- define "bedag-lib.presets.readiness.overwrites" -}}
containerName: {{ default "readiness" .name }}
command:
  - /bin/sh
args:
  - -ec
  - |
      #!/bin/bash
      URL="{{ required "Required '.url' was not provided!" .values.url }}"
      STATUS_CODES=( "200" )
      RETRY_COUNT=0;
      RETRIES={{ .values.retries }};
      LOOPER=1;

      while [ $LOOPER ];
      do
        RETURNED_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k {{ if .values.auth }}{{- if and .values.auth.user .values.auth.password }}-u {{.values.auth.user}}:{{.values.auth.password}}{{- end }}{{- end }} $URL);
        echo "Calling $URL - Responded with $RETURNED_CODE - Attempt $RETRY_COUNT/$RETRIES"

        if [[ " ${STATUS_CODES[@]} " =~ " ${RETURNED_CODE} " ]]; then
          echo -e "\nReceived allowed status code: $RETURNED_CODE\n" && exit 0;
        else
          if [ $RETRY_COUNT -eq $RETRIES ]; then
           echo -e "\nMaximum Retries reached!\n" && exit 1;
          else
           RETRY_COUNT=$(($RETRY_COUNT + 1));
           sleep {{ .values.wait }};
          fi;
        fi
      done;
securityContext:
  runAsUser: 0
{{- end }}
