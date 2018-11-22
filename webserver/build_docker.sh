# https://github.com/ktorio/ktor-samples/tree/master/deployment/docker

./gradlew :build
docker build -t ktor-deployed-attwell-1 .

# Run this with the following:
# docker run -m512M --cpus 2 -it -p 8080:8080 --rm ktor-docker-sample-application


# TODO: working on this...
aws ecr create-repository --repository-name ktor-deployed-attwell-1
$(aws ecr get-login --no-include-email)
docker push 697071018446.dkr.ecr.us-east-1.amazonaws.com/ktor-deployed-attwell-1