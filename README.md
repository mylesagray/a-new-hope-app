# Runbook

Deploy TKC:

```sh
kubectl apply -f manifests/tkc.yaml
```

Install ArgoCD:

```sh
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Make it externally accessible
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
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

kubectl patch serviceaccount -n monitoring default \
  -p "{\"imagePullSecrets\": [{\"name\": \"$SECRETNAME\"}]}"

kubectl patch serviceaccount -n flower-market default \
  -p "{\"imagePullSecrets\": [{\"name\": \"$SECRETNAME\"}]}"
```
