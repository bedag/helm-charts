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
{{ define "bedag-lib.utils.helpers.javaProxies" -}}
  {{- if .proxy -}}
    {{- $proxies := (include "lib.utils.strings.template" ( dict "value" .proxy "context" .context)) | fromYaml -}}
    {{- $noproxies := "" -}}
    {{- if .proxy.noProxy -}}
      {{- if kindIs "slice" .proxy.noProxy -}}
        {{- $noproxies = (join "|" .proxy.noProxy) -}}
      {{- else -}}
        {{- $noproxies = .proxy.noProxy -}}
      {{- end -}}
    {{- end -}}
    {{- printf "-Dhttp.proxyHost=\"%s\" -Dhttp.proxyPort=\"%s\" -Dhttp.nonProxyHosts=\"%s\" -Dhttps.proxyHost=\"%s\" -Dhttps.proxyPort=\"%s\" -Dhttps.nonProxyHosts=\"%s\"" (default "" $proxies.httpProxy.host) (default "" $proxies.httpProxy.port) $noproxies (default "" $proxies.httpsProxy.host) (default "" $proxies.httpsProxy.port) $noproxies -}}
  {{- end -}}
{{- end -}}
