# helm-quote
docker-terraform-kubernetes-helm deplyement project


## port-forward for kubernets
```
kubectl port-forward svc/quote-backend 8080:8080 -n quote-app
```
## start minikube with nginx ingress add-on
```
minikube start --addons=ingress

# or if minikube has started - ingress-rules.yaml 
minikube addons enable 

# to check if the ingress controller is installed
kubectl get ingress -n quote-app
kubectl get svc -n quote-app
minikube ip

``` 
## to check if ingess-nginx is running as a loadbalancer
```
kubectl get svc -n ingress-nginx

# or more details
kubectl get svc ingress-nginx-controller -n ingress-nginx -o wide
``` 

## dockerhub/ECR integration 

Simple approach:
```
# authenticate with dockerhub
docker login

# Authenticate Docker to ECR (update region accordingly)
aws ecr get-login-password \
  --region eu-west-1 | \
  docker login --username AWS \
  --password-stdin 040929397520.dkr.ecr.eu-west-1.amazonaws.com

# Create an ECR repository
aws ecr create-repository --repository-name quote_frontend

aws ecr create-repository \
  --repository-name your-repo-name \
  --region eu-west-2

# or more details
aws ecr create-repository \
  --repository-name quote-backend \
  --region eu-west-2 \
  --image-scanning-configuration scanOnPush=true \
  --tags Key=project,Value=new-dawn
```

Full ECR ingration with kubernetes secret:
```
aws ecr get-login-password --region eu-west-2 | \
  docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com

kubectl create secret docker-registry ecr-secret \
  --docker-server=<aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region eu-west-2) \
  --docker-email=you@example.com \
  --namespace=quote-app

# reference that secret in the pod/deployment YAML:
spec:
  imagePullSecrets:
    - name: ecr-secret

# Use the full ECR image path in the container spec
containers:
  - name: backend
    image: <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/quote-backend:latest
```

To load a new image lto local docker daemon
```
docker buildx build --no-cache --platform=linux/amd64 -t quote-backend:v1000 ./backend --load
```

To build and push to dockerhub/ECR
```
docker buildx build --platform=linux/amd64,linux/arm64 --no-cache --push -t 040929397520.dkr.ecr.eu-west-1.amazonaws.com/quote_frontend:v1001 ./quote_frontend
docker buildx build --platform=linux/amd64,linux/arm64 --no-cache --push -t 040929397520.dkr.ecr.eu-west-1.amazonaws.com/quote_backend:v1001 ./quote_backend
```
Alternativ approache for minikube: load local image into minikube skip ECR - for testing
```
minikube image load quote-backend:latest

# refrence it in the yaml
image: quote-backend:latest
```
## to test any deployemnet was success - exmaple busybox
steps can be used on any deployment.yaml files 

### ✅ 1. Check if the namespace and pod exist
```
kubectl get ns

# Make sure the app (example: quote-app) is listed.

kubectl get pod -n quote-app

# or for services

kubectl get svc -n quote-app

```

You should see something like:
```
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          10s
```

If the status is not Running, run:
```
kubectl describe pod busybox -n quote-app
kubectl logs busybox -n quote-app
```

### 🧪 2. Exec into the BusyBox pod
To troubleshoot why it's not starting.
Once it's in Running state, exec into it:
```
kubectl exec -it busybox -n quote-app -- sh
```
That gives a BusyBox shell. Now can run commands like ls, ping, nslookup, etc.

To delete any pod (example: busybox)
```
kubectl delete pod busybox -n quote-app
```

### 🧪 Tip to test if image is present on node (inside Minikube):
```
minikube ssh
docker images | grep quote-backend
```

## misc
To stop and remoe nginx services - mac
```
brew services stop nginx
brew uninstall nginx
sudo rm -rf /usr/local/etc/nginx  # config files
sudo rm -rf /usr/local/var/log/nginx  # logs
```

To stop and remoe nginx services - ubuntu
```
sudo systemctl stop nginx
sudo systemctl disable nginx
sudo apt remove nginx nginx-common -y
sudo apt purge nginx nginx-common -y
sudo rm -rf /etc/nginx /var/log/nginx /var/www/html
```

## NOTE:
if Ingress addon is enabled and ingress-rules.yaml is applied + minikube tunnel, then test is 
```
 ~/p/helm-quote [main] % curl http://localhost/quote

{
    "server": "snippy-papaya-ffym1lgj",
    "quote": "The light at the end of the tunnel is interdependent on the relatedness of motivation, subcultures, and management.",
    "time": "2025-08-04T17:49:41.141131Z"
}
```      

## metrics server and horizontal-pod-autoscaler HPA
For mk
```
minikube addons enable metrics-server

# Give it ~10–15 seconds, then check:

kubectl get deployment metrics-server -n kube-system
kubectl top pods -n quote-app
```
To monitor HPA activities 
```
kubectl get hpa -n quote-app --watch

# to delete after the test

kubectl delete deployment frontend-load-generator -n quote-app
```

## ✅ Option 1: Bash + curl (Simple loop)

#!/bin/bash
while true; do
  curl -s http://localhost/quote > /dev/null
done

📌 Save as stress-backend.sh, then run:

chmod +x stress-backend.sh
./stress-backend.sh

## ✅ Option 2: Parallel curl flood (lightweight load test)

#!/bin/bash
for i in {1..20}; do
  while true; do
    curl -s http://localhost/ > /dev/null &
    curl -s http://localhost/quote > /dev/null &
    sleep 0.2
  done
done

## 📌 Save as hammer.sh, run:

chmod +x hammer.sh
./hammer.sh

This simulates 20+ users hitting your frontend and backend rapidly.
## ✅ Option 3: Use hey — a proper CLI load tester

Install via Homebrew:

brew install hey

Then test the frontend:

hey -z 30s -c 20 http://localhost/

Or backend:

hey -z 30s -c 20 http://localhost/quote

    -z 30s → duration

    -c 20 → 20 concurrent users

## 📈 Then monitor HPA:

kubectl get hpa -n quote-app --watch

You’ll see replicas climb as CPU spikes.

# helm setup
## ✅ Helm dry-run

Run:

helm template quote-app ./quote-app \
  --namespace quote-app \
  --values quote-app/values.yaml


to deploy

helm upgrade --install quote-app ./quote-app \
  --namespace quote-app


to test

kubectl exec -it busybox -n quote-app -- wget -qO- http://quote-app-backend:8080


 ~/p/helm-quote [feature/helm] (tf:dev) % helm template quote-app ./quote-app \
  --namespace quote-app \
  --show-only templates/03-frontend-deployment.yaml

---
# Source: quote-app/templates/03-frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quote-app-frontend
  labels:
    app.kubernetes.io/name: quote-app
    app.kubernetes.io/instance: quote-app
    app.kubernetes.io/managed-by: Helm
    helm.sh/chart: quote-app-0.1.0
spec:
  replicas: 1
  selector:
    matchLabels:
      app: quote-frontend
  template:
    metadata:
      labels:
        app: quote-frontend
    spec:
      containers:
        - name: frontend
          image: timursamanchi/quote-frontend:zzz
          imagePullPolicy: Always
          ports:
            - containerPort: 80
          resources:
            limits:
              cpu: 500m
              memory: 512Mi
            requests:
              cpu: 100m
              memory: 128Mi
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            timeoutSeconds: 2
            periodSeconds: 10
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            timeoutSeconds: 2
            periodSeconds: 15
 ~/p/helm-quote [feature/helm] (tf:dev) % 