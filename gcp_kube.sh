#!/usr/bin/env bash

# not certain this is necessary. Could probably do this with minikube.
# maybe I'll just put the docker image in mini-kube. Then

gcloud components install kubectl
gcloud config set project testproject-224403
gcloud config set compute/zone us-central1-b

export PROJECT_ID="$(gcloud config get-value project -q)"
#docker build -t gcr.io/${PROJECT_ID}/hello-app:v1 .