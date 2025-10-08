{{/* Generate a name for resources */}}
{{- define "python-api.name" -}}
python-rest-api
{{- end -}}

{{- define "python-api.fullname" -}}
{{ include "python-api.name" . }}
{{- end -}}
