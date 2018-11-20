#sudo apt install yum -y

#sudo apt install awscli -y
#sudo apt install docker.io -y
#sudo service docker start

# Run on startup
DOCKER_LOGIN="sudo "`aws ecr get-login`
$(echo $DOCKER_LOGIN)

#docker pull 697071018446.dkr.ecr.us-east-1.amazonaws.com/hello-world
sudo docker run -p 80:80 697071018446.dkr.ecr.us-east-1.amazonaws.com/hello-world