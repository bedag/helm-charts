{{- /*
library.chartref prints a chart name and version.
It does minimal escaping for use in Kubernetes labels.
Example input:
  .Chart.Name: zookeeper ; .Chart.Version: 1.2.3+experimentalbuild
  .Chart.Name: wordpress ; .Chart.Version: 3.2.1-beta+9df8181193c0f933dc7ded9a4628da555ffcb318
Example output:
  zookeeper-1.2.3_experimentalbuild
  wordpress-3.2.1-beta_9df8181193c0f933dc7ded9a4628da555ffcb318
*/ -}}
{{- define "library.chartref" -}}
  {{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end -}}

{{- /*
library.chartrefshort prints a chart name and version without the semver metadata field
It does minimal escaping for use in Kubernetes labels.
Example input:
  .Chart.Name: zookeeper ; .Chart.Version: 1.2.3+experimentalbuild
  .Chart.Name: wordpress ; .Chart.Version: 3.2.1-beta+9df8181193c0f933dc7ded9a4628da555ffcb318
Example output:
  zookeeper-1.2.3
  wordpress-3.2.1-beta
*/ -}}
{{- define "library.chartrefshort" -}}
  {{- if (include "library.chartver.prerelease" .) -}}
    {{- include "library.chartver.majminpatpre" . | printf "%s-%s" .Chart.Name -}}
  {{- else -}}
    {{- include "library.chartver.majminpat" . | printf "%s-%s" .Chart.Name -}}
  {{- end -}}
{{- end -}}
