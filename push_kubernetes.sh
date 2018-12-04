#!/usr/bin/env bash

# Create docker and push to local docker registry
cd webserver
./gradlew build
docker build -t ktor-local-image-attwell .
cd ..

# Install or upgrade kubernetes using new container from docker registry
# Can locally run with: docker run -i -t ktor-local-image-attwell
helm install agario_helm