# helm-quote
docker-terraform-kubernetes-helm deplyement project


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