# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"
  vpc_id        = "<Your VPC>"
  subnet_id     = "Your Subnet"

  source_ami_filter {
    filters = {
		  # COMPLETE ME complete the "name" argument below to use Ubuntu 24.04
      name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] 
	}

  ssh_username = "ubuntu"
  associate_public_ip_address = true

}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    # COMPLETE ME Use the source defined above
    "source.amazon-ebs.ubuntu"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      # COMPLETE ME add inline scripts to create necessary directories and change directory ownership.
      "sudo mkdir -p /web/html",
      "sudo mkdir /tmp/web",
      "sudo chown -R ubuntu:ubuntu /tmp/web/"

    ]
  }

  provisioner "file" {
    # COMPLETE ME add the HTML file to your image
    source      = "files/nginx.conf"
    destination = "/tmp/web/nginx.conf"

  }

  provisioner "file" {
    # COMPLETE ME add the nginx.conf file to your image

    source      = "files/index.html"
    destination = "/tmp/index.html"
   
  }
  provisioner "shell" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get install nginx -y",
      "sudo cp /tmp/web/nginx.conf /etc/nginx/sites-available/",
      "sudo unlink /etc/nginx/sites-enabled/*",
      "sudo ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/",
      "sudo mv /tmp/index.html /web/html/index.html",
      "sudo chown www-data:www-data /web/html/index.html",
      "sudo chmod 644 /web/html/index.html"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable ssh",
      "sudo systemctl start ssh"

    ]
  }
  # COM
  # COMPLETE ME add additional provisioners to run shell scripts and complete any other tasks
}

