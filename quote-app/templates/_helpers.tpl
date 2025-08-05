{{/* 
  Generate full name for resources: 
  example: quote-app-backend
*/}}
{{- define "quote-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* 
  Short name for app (used in labels, optional)
*/}}
{{- define "quote-app.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{/* 
  Standard labels used across all resources 
*/}}
{{- define "quote-app.labels" -}}
app.kubernetes.io/name: {{ include "quote-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
