provider "aws" {
  region     = "ap-south-1"
  access_key = "<Enter-your-aws-access-key>"
  secret_key = "<Enter-your-aws-secret-key>"
}

resource "aws_instance" "master" {
  ami           = "ami-05a5bb48beb785bf1"
  instance_type = "t3.medium"
  key_name      = "Yash-kube"

  security_groups = [aws_security_group.master_worker.name]

  associate_public_ip_address = false
  root_block_device {
    volume_size           = 15
  }
  tags = {
    Name = "redhat-master"
  }
}

resource "aws_instance" "worker" {
  ami           = "ami-05a5bb48beb785bf1"
  instance_type = "t3.medium"
  key_name      = "Yash-kube"

  security_groups = [aws_security_group.master_worker.name]

  associate_public_ip_address = false
  root_block_device {
    volume_size           = 15
  }
  tags = {
    Name = "redhat-worker"
  }
}

resource "local_file" "inventory_file" {

  depends_on = [ aws_instance.master, aws_instance.worker ]
  filename = "./ansible_playbooks/hosts"

  content = <<EOF
  [master]
  ${aws_instance.master.private_ip} ansible_user=ec2-user 

  [worker]
  ${aws_instance.worker.private_ip} ansible_user=ec2-user 

  [all:vars]
  #default values
  host_key_checking=false
  ansible_ssh_private_key_file=Yash-kube.pem
  ask_pass=false
  ansible_ssh_common_args='-o StrictHostKeyChecking=no'

  #default previleges
  ansible_become=true
  ansible_become_user=root
  EOF
}

resource "aws_instance" "rhel_bastion" {

  depends_on = [local_file.inventory_file]
  ami           = "ami-05a5bb48beb785bf1"
  instance_type = "t2.micro"
  key_name      = "Yash-kube"

  security_groups = [aws_security_group.rhel_bastion.name]
  root_block_device {
    volume_size           = 10
  }
  provisioner "file" {
    source     = "./ansible_playbooks"
    destination = "/home/ec2-user"
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./ansible_playbooks/Yash-kube.pem")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y ansible-core",
      "cd ansible_playbooks",
      "sudo chmod 600 Yash-kube.pem",
      "ansible-playbook allinone.yml -i hosts -b"
    ]
  }
  tags = {
    Name = "redhat-bastion"
  }
}

resource "aws_security_group" "rhel_bastion" {
  name        = "rhel_bastion"
  description = "Allow SSH access from any IP to bastion instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rhel_bastion"
  }
}

resource "aws_security_group" "master_worker" {
  name        = "master_worker"
  description = "Allow SSH access from bastion instance to master and worker instances"

  ingress {
    from_port          = 22
    to_port            = 22
    protocol           = "tcp"
    security_groups = [aws_security_group.rhel_bastion.id]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "4"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "master_worker"
  }
}
