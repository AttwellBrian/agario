This repo is in a rough state. The game mechanics aren't fleshed out. And the file structure is a mess. However, the communication via websocket is in place, the build scripts are rouhgly in place as well as the AWS deployment scripts.

# Deployment

Terraform sets up a single EC2 instance that loads a docker container from amazon's container service.

## Initialize
If this is the first time you're building, you'll need to create the EC2 ABI. This should only ever need to be done once. You can do this by running `packer build infra/ami.js` and then modifying the `instance` field in `main.tf`.

This will upload the ami to S3. It will cost 1 cent per month in perpetuity. You will need to setup your `~/.aws/` directory before any of these scripts work.

## Deployment
Push the docker container with `push_docker.sh`. Then re-deploy infastructure with `terraform apply -auto-approve`.


