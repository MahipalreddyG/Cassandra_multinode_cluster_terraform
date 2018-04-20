provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-west-2"
}

# Launching 3 Instances

resource "aws_instance" "hello" {
  ami = "ami-4e79ed36"
  instance_type = "t2.micro"
  key_name="aws"
  security_groups=["launch-wizard-1"]
  count="3"
  tags{
    Name="Node-${count.index}"
  }
 connection {
  user = "ubuntu"
  type = "ssh"
  private_key="${file("/home/ubuntu/aws.pem")}"
  }

# Capture the IPs of recently launched
  
  provisioner "local-exec" {
     command = "echo ${self.private_ip} >> /tmp/ips.txt"
  }
  
# Copying the IPs file into remote machine
  
  provisioner "file" {
    source      = "/tmp/ips.txt"
    destination = "/tmp/ips.txt"
  }
  
# Using script.sh install the Cassandra on 3 instances
  
  provisioner "file" {
    source      = "/home/ubuntu/terraform/script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args",
      ]
  }
  
# Give the full permissions to /etc/cassandra/
  
  provisioner "remote-exec" {
    inline = [
        "sudo chmod 777 /etc/cassandra/",
        "sudo mv /etc/cassandra/cassandra.yaml /etc/cassandra/cassandra.yaml.bkp",
      ]
  }
  
# Replace the cassandra.yaml file with our own cassandra.yaml for easylly change the parameters
  
  provisioner "file" {
    source      = "/home/ubuntu/cassandra.yaml"
    destination = "/etc/cassandra/cassandra.yaml"
  }

# Do the changes in cassandra.yaml using with config.sh
  
  provisioner "file" {
    source      = "/home/ubuntu/config.sh"
    destination = "/tmp/config.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/config.sh",
      "/tmp/config.sh args",
      "sudo service cassandra restart"
      ]
  }
}
