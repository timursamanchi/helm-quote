# this the template for the load-generator.yaml stress test tool - move to helm/template folder to test on add-hoc basis.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "quote-app.fullname" . }}-load-generator
  namespace: {{ .Values.namespace }}
  labels:
    app: {{ include "quote-app.name" . }}-load-generator
    app.kubernetes.io/name: {{ include "quote-app.name" . }}
    helm.sh/chart: {{ include "quote-app.chart" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ include "quote-app.name" . }}-load-generator
  template:
    metadata:
      labels:
        app: {{ include "quote-app.name" . }}-load-generator
    spec:
      containers:
        - name: busybox
          image: busybox
          command: ["/bin/sh", "-c"]
          args:
            - >
              while true; do
                wget -q -O- http://{{ include "quote-app.fullname" . }}-backend:8080/quote;
                sleep 0.1;
              done
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
            limits:
              cpu: 50m
              memory: 32Mi
