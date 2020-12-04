# Runbook

Deploy TKC:

```sh
kubectl apply -f manifests/tkc.yaml
```

Apply Pod Security Policy:

```sh
kubectl apply -f manifests/app/psp-policy.yaml
```

Create three namespaces:

```sh
kubectl create ns argocd
kubectl create ns monitoring
kubectl create ns flower-market
```

Deploy secret containing Docker Hub token for image pulls:

```sh
SECRETNAME=regcred
UN=username here
PW=password here
EMAIL=email here

kubectl create secret docker-registry $SECRETNAME \
  --docker-username=$UN \
  --docker-password=$PW \
  --docker-email=$EMAIL

# Copy secret to other namespaces
kubectl get secret $SECRETNAME -n default -o yaml \
| sed s/"namespace: default"/"namespace: argocd"/\
| kubectl apply --namespace=argocd -f -
kubectl get secret $SECRETNAME -n default -o yaml \
| sed s/"namespace: default"/"namespace: monitoring"/\
| kubectl apply --namespace=monitoring -f -
kubectl get secret $SECRETNAME -n default -o yaml \
| sed s/"namespace: default"/"namespace: flower-market"/\
| kubectl apply --namespace=flower-market -f -

# Apply docker registry creds to each serviceaccount
kubectl patch serviceaccount -n argocd default \
  -p "{\"imagePullSecrets\": [{\"name\": \"$SECRETNAME\"}]}"

kubectl patch serviceaccount -n monitoring default \
  -p "{\"imagePullSecrets\": [{\"name\": \"$SECRETNAME\"}]}"

kubectl patch serviceaccount -n flower-market default \
  -p "{\"imagePullSecrets\": [{\"name\": \"$SECRETNAME\"}]}"
```

Install ArgoCD:

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd --namespace argocd argo/argo-cd --set global.imagePullSecrets\[0\].name=regcred --set server.service.type=LoadBalancer
# Get password
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

Create ArgoCD application for Prometheus:

```sh
kubectl apply -f argocd/prometheus.yaml
```

Create ArgoCD application for application:

```sh
kubectl apply -f argocd/a-new-hope.yaml
```
