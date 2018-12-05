#!/usr/bin/env bash

# Create local docker registry with the following first
# docker run -d -p 50000:5000 --restart always --name my-registry registry:latest
# https://code-maze.com/docker-hub-vs-creating-docker-registry/
# See http://localhost:50000/v2/_catalog
# Then  ... via https://blog.hasura.io/sharing-a-local-registry-for-minikube-37c7240d0615
# ssh -i ~/.docker/machine/machines/default/id_rsa -R 5000:localhost:5000 docker@$(docker-machine ip)




export PROJECT_ID="$(gcloud config get-value project -q)"

# Create docker and push to local docker registry
cd webserver
./gradlew build
#docker build -t ktor-local-image-attwell-1 .
docker build -t gcr.io/${PROJECT_ID}/ktor-attwell-gcp:v1 .
cd ..

#docker push ktor-local-image-attwell-1
#docker tag ktor-local-image-attwell-1 registry.minikube.st81ess.com:80/ktor-attwell
#docker push registry.minikube.st81ess.com:80/ktor-attwell


# Install or upgrade kubernetes using new container from docker registry
# Can locally run with: docker run -i -t ktor-local-image-attwell


gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/ktor-attwell-gcp:v1


# The key to getting this working was
#   https://cloud.google.com/solutions/continuous-integration-helm-concourse ...
#   https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app

helm install agario_helm
# or update with something like helm upgrade angry-termite agario_helm



# gcloud container clusters get-credentials standard-cluster-1