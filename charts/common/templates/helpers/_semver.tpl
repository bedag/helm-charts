{{- /*
Splits up .Chart.Version in its different SemVer fields
*/ -}}
{{- define "library.chartver.major" -}}
  {{- regexReplaceAll "^[^0-9]*([0-9]*)([.]([0-9]*))?([.]([0-9]*))?(-([.0-9A-Za-z-]*))?([+](.*))?$" .Chart.Version "${1}" -}}
{{- end -}}
{{- define "library.chartver.minor" -}}
  {{- regexReplaceAll "^[^0-9]*([0-9]*)([.]([0-9]*))?([.]([0-9]*))?(-([.0-9A-Za-z-]*))?([+](.*))?$" .Chart.Version "${3}" -}}
{{- end -}}
{{- define "library.chartver.patch" -}}
  {{- regexReplaceAll "^[^0-9]*([0-9]*)([.]([0-9]*))?([.]([0-9]*))?(-([.0-9A-Za-z-]*))?([+](.*))?$" .Chart.Version "${5}" -}}
{{- end -}}
{{- define "library.chartver.prerelease" -}}
  {{- regexReplaceAll "^[^0-9]*([0-9]*)([.]([0-9]*))?([.]([0-9]*))?(-([.0-9A-Za-z-]*))?([+](.*))?$" .Chart.Version "${7}" -}}
{{- end -}}
{{- define "library.chartver.meta" -}}
  {{- regexReplaceAll "^[^0-9]*([0-9]*)([.]([0-9]*))?([.]([0-9]*))?(-([.0-9A-Za-z-]*))?([+](.*))?$" .Chart.Version "${9}" -}}
{{- end -}}

{{- /*
Common version patterns:
1.2.3-beta and 1.2.3
*/ -}}
{{- define "library.chartver.majminpatpre" -}}
  {{- regexReplaceAll "^[^0-9]*([0-9]*)([.]([0-9]*))?([.]([0-9]*))?(-([.0-9A-Za-z-]*))?([+](.*))?$" .Chart.Version "${1}.${3}.${5}-${7}" -}}
{{- end -}}
{{- define "library.chartver.majminpat" -}}
  {{- regexReplaceAll "^[^0-9]*([0-9]*)([.]([0-9]*))?([.]([0-9]*))?(-([.0-9A-Za-z-]*))?([+](.*))?$" .Chart.Version "${1}.${3}.${5}" -}}
{{- end -}}