# Runbook

Deploy TKC:

```sh
kubectl apply -f manifests/tkc.yaml
```

Deploy allow all PSP:

```sh
kubectl create clusterrolebinding default-tkg-admin-privileged-binding --clusterrole=psp:vmware-system-privileged --group=system:authenticated
```

Deploy Prometheus:

```sh
cd kube-prometheus
kubectl create -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f manifests/
```

Deploy app:

```sh
kubectl apply -f manifests/app/
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
