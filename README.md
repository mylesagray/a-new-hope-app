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
export UN=usernamehere
export PW=passwordhere
export EMAIL=emailhere

kubectl create secret docker-registry docker-creds \
  --namespace kube-system \
  --docker-username=$UN \
  --docker-password=$PW \
  --docker-email=$EMAIL
```

Create reg-cred operator to sync imagepullsecrets across namespaces (because, Docker...)

```sh
kubectl apply -f https://raw.githubusercontent.com/mylesagray/home-cluster-gitops/master/manifests/registry-creds/manifest.yaml
```

Create ClusterPullSecret CR

```sh
kubectl apply -f manifests/app/regcred-crd.yaml
```

Deploy Prometheus:

```sh
kubectl apply -f kube-prometheus/manifests/setup

kubectl apply -f kube-prometheus/manifests
```

Deploy Application:

```sh
kubectl apply -f manifests/app
```
