{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pihole.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pihole.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pihole.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Default password secret name.
*/}}
{{- define "pihole.password-secret" -}}
{{- printf "%s-%s" (include "pihole.fullname" .) "password" | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The kind of workload to render, either "Deployment" or "StatefulSet".
*/}}
{{- define "pihole.kind" -}}
{{- $kind := .Values.deploymentMode | default "Deployment" -}}
{{- if not (has $kind (list "Deployment" "StatefulSet")) -}}
{{- fail (printf "deploymentMode must be either \"Deployment\" or \"StatefulSet\", got %q" $kind) -}}
{{- end -}}
{{- $kind -}}
{{- end -}}

{{/*
Returns a non empty string when the config volume is provisioned per replica
through the StatefulSet `volumeClaimTemplates` instead of a single shared
PersistentVolumeClaim.
*/}}
{{- define "pihole.useVolumeClaimTemplate" -}}
{{- if and (eq (include "pihole.kind" .) "StatefulSet") .Values.statefulset.volumeClaimTemplates.enabled .Values.persistentVolumeClaim.enabled (not .Values.persistentVolumeClaim.existingClaim) -}}
true
{{- end -}}
{{- end -}}

{{/*
The service that governs the StatefulSet, used as `spec.serviceName`.
*/}}
{{- define "pihole.statefulset.serviceName" -}}
{{- if .Values.statefulset.serviceName -}}
{{- .Values.statefulset.serviceName -}}
{{- else if .Values.statefulset.headlessService.enabled -}}
{{- printf "%s-headless" (include "pihole.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "pihole.fullname" . -}}
{{- end -}}
{{- end -}}
