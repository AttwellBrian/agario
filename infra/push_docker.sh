#!/usr/bin/env bash
# From https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#docker-basics-create-image

# should also include a build step here.

aws ecr create-repository --repository-name hello-world-2
# docker tag hello-world aws_account_id.dkr.ecr.us-east-1.amazonaws.com/hello-world
docker tag hello-world 697071018446.dkr.ecr.us-east-1.amazonaws.com/hello-world-2
# docker push aws_account_id.dkr.ecr.us-east-1.amazonaws.com/hello-world

# Get login command, then execute it.
$(aws ecr get-login --no-include-email)

docker push 697071018446.dkr.ecr.us-east-1.amazonaws.com/hello-world-2