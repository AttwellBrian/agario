# https://github.com/ktorio/ktor-samples/tree/master/deployment/docker

./gradlew :build
docker build -t ktor-docker-sample-application .

# Run this with the following:
# docker run -m512M --cpus 2 -it -p 8080:8080 --rm ktor-docker-sample-application