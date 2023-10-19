{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "vearch-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "vearch-helm.namespace" -}}
{{- .Release.Namespace | default .Values.namespace -}}
{{- end -}}

{{- define "vearch.master.peers" -}}
{{- range $i, $e := until (.Values.master.replicas | int) -}}
master-{{- $.Release.Name -}}-{{ $i | add1  }}.master-service.{{- $.Values.namespace -}}.svc.cluster.local
{{- end -}}
{{- end -}}

{{- define "vearch.master.master-service" -}}
master-service-{{- $.Release.Name -}}.{{- $.Values.namespace -}}.svc.cluster.local
{{- end -}}

{{- define "vearch.router.router-service" -}}
router-service-{{- $.Release.Name -}}.{{- $.Values.namespace -}}.svc.cluster.local
{{- end -}}

{{- define "vearch.monitor.consul.address" -}}
{{- $envAll := index . 0 -}}
consul-service-{{- $envAll.Release.Name -}}.{{- $envAll.Values.namespace -}}.svc.cluster.local:{{- $envAll.Values.consul.port }}
{{- end -}}

{{- define "vearch.monitor.consul.url" -}}
{{- $envAll := index . 0 -}}
http://consul-service-{{- $envAll.Release.Name -}}.{{- $envAll.Values.namespace -}}.svc.cluster.local:{{- $envAll.Values.consul.port }}
{{- end -}}

{{- define "vearch.monitor.prometheus.url" -}}
{{- $envAll := index . 0 -}}
http://prometheus-service-{{- $envAll.Release.Name -}}.{{- $envAll.Values.namespace -}}.svc.cluster.local:{{- $envAll.Values.prometheus.port }}
{{- end -}}

{{- define "helm-toolkit.metadata_labels" -}}
{{- $envAll := index . 0 -}}
{{- $application := index . 1 -}}
{{- $component := index . 2 -}}
app.kubernetes.io/app: {{ $envAll.Chart.Name }}
app.kubernetes.io/version: {{ $envAll.Chart.Version }}
app.kubernetes.io/instance: {{ $application }}
app.kubernetes.io/components: {{ $component }}
app.kubernetes.io/managed-by: helm
{{- end -}}

{{- define "helm-toolkit.utils.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $last := base $context.Template.Name }}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{- define "helm-toolkit.utils.container_port" -}}
{{- $envAll := index . 0 -}}
{{- $name := index . 1 -}}
{{- $containerPort := index . 2 -}}
- name: {{ $name }}
  containerPort: {{ $containerPort }}
  protocol: TCP
{{- end -}}

{{- define "helm-toolkit.utils.env" -}}
{{- $envAll := index . 0 -}}
env:
  - name: GLOBAL_NAME
    value: {{ $envAll.Release.Name }}
  - name: NAMESPACE
    value: {{ $envAll.Values.namespace }}
  - name: GLOBAL_DATA
    value: {{ $envAll.Values.global.data }}
  - name: GLOBAL_LOG
    value: {{ $envAll.Values.global.log }}
  - name: GLOBAL_LEVEL
    value: {{ $envAll.Values.global.level }}
  - name: GLOBAL_SIGNKEY
    value: {{ $envAll.Values.global.signkey }}
  - name: GLOBAL_SKIP_AUTH
    value: {{ $envAll.Values.global.skip_auth | quote }} 
  - name: GLOBAL_SELF_MANAGE_ETCD
    value: {{ $envAll.Values.global.self_manage_etcd | quote }}
  - name: VEARCH_MASTER_NUM
    value: {{ $envAll.Values.master.replicas | quote }}
  - name: VEARCH_MASTER_API_PORT
    value: {{ $envAll.Values.master.api_port | quote }}
  - name: VEARCH_MASTER_MONITOR_PORT
    value: {{ $envAll.Values.master.monitor_port | quote }}
  - name: VEARCH_ROUTER_PORT
    value: {{ $envAll.Values.router.port | quote }}
  - name: VEARCH_ROUTER_MONITOR_PORT
    value: {{ $envAll.Values.router.monitor_port | quote }}
  - name: VEARCH_ETCD_ADDRESS
    value: {{ $envAll.Values.etcd.address | quote }}
  - name: VEARCH_ETCD_PORT
    value: {{ $envAll.Values.etcd.port | quote }}
  - name: VEARCH_ETCD_USER
    value: {{ $envAll.Values.etcd.user | quote }}
  - name: VEARCH_ETCD_PWD
    value: {{ $envAll.Values.etcd.pwd | quote }}
  - name: PODIP
    valueFrom: 
      fieldRef:
        fieldPath: status.podIP
{{- end -}}

{{- define "helm-toolkit.snippets.kubernetes_resources" -}}
{{- $envAll := index . 0 -}}
{{- $component := index . 1 -}}
{{- if $component.enabled -}}
resources:
  limits:
    cpu: {{ $component.limits.cpu | quote }}
    memory: {{ $component.limits.memory | quote }}
  requests:
    cpu: {{ $component.requests.cpu | quote }}
    memory: {{ $component.requests.memory | quote }}
{{- end -}}
{{- end -}}

