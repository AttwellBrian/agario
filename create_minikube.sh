#!/usr/bin/env bash

# with local docker registry we can push to
# https://sethlakowske.com/articles/howto-local-minikube-registry/
minikube start --cpus 2 --disk-size 2g --memory 1000 --insecure-registry registry.minikube.st81ess.com:80

helm repo add lakowske https://lakowske.github.io/charts
#After adding the repo, update your index.
helm repo update
helm init ; kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system


helm install lakowske/minikube-registry

#kubectl run hello-node --image=registry.minikube.st81ess.com:80/hello-node --port=8888
