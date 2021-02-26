# Runbook

Deploy TKC:

```sh
kubectl apply -f manifests/tkc.yaml
```

Apply Pod Security Policy:

```sh
kubectl apply -f manifests/setup-k8s/psp.yaml
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
kubectl apply -f manifests/setup-k8s/regcred-crd.yaml
```

Define custom metric:

```sh
# Metric for this app is defined at 
# kube-prometheus/vendor/kube-prometheus/kube-prometheus-custom-metrics.libsonnet Lines 12-30
```

Build Prometheus:

```sh
cd kube-prometheus/
./build.sh
```

Deploy Prometheus:

```sh
kubectl apply -f manifests/setup-k8s/prometheus-rbac.yaml

kubectl apply -f kube-prometheus/manifests/setup

kubectl apply -f kube-prometheus/manifests
```

Deploy Application:

```sh
kubectl apply -f manifests/app
```

The HPA algorithm to calculate desired scale is:

```sh
desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]
```
