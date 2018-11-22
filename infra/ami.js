{
  "variables": {
    "home": "{{env `HOME`}}"
  },
  "builders": [{
    "ami_name": "packer-example-5",
    "instance_type": "t2.micro",
    "region": "us-east-1",
    "type": "amazon-ebs",
    "source_ami": "ami-40d28157",
    "ssh_username": "ubuntu"
  }],
  "provisioners": [
  {
    "type": "shell",
    "inline": [
      "mkdir /home/ubuntu/.aws/"
    ]
  },
  {
    "destination": "/home/ubuntu/.aws/config",
    "source": "{{ user `home` }}/.aws/config",
    "type": "file"
  },
  {
    "destination": "/home/ubuntu/.aws/credentials",
    "source": "{{ user `home` }}/.aws/credentials",
    "type": "file"
  },
  {
    "type": "shell",
    "inline": [
      "sudo apt-get update",
      "sudo apt install awscli -y",
      "sudo apt install docker.io -y",
      "sudo service docker start"
    ]
  }]
}
