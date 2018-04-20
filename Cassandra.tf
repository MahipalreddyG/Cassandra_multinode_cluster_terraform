provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-west-2"
}

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
  provisioner "local-exec" {
     command = "echo ${self.private_ip} >> /tmp/ips.txt"
  }
  provisioner "file" {
    source      = "/tmp/ips.txt"
    destination = "/tmp/ips.txt"
  }
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
  provisioner "remote-exec" {
    inline = [
        "sudo chmod 777 /etc/cassandra/",
        "sudo mv /etc/cassandra/cassandra.yaml /etc/cassandra/cassandra.yaml.bkp",
      ]
  }
  provisioner "file" {
    source      = "/home/ubuntu/cassandra.yaml"
    destination = "/etc/cassandra/cassandra.yaml"
  }
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
