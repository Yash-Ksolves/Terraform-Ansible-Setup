
This guide will help you set up a Kubernetes cluster using Terraform and Ansible. The process involves creating three instances - bastion, worker, and master, and configuring them using Ansible playbooks.

## Prerequisites

-  AWS account with access-key
- `Yash-kube.pem` key pair for SSH access, you can find it in `redhat` folder.
-  Please make sure to update AWS credential keys in `create_instance.tf` file.

## Steps

1. **Clone Git Repo:**

    ```bash
    git clone https://github.com/Yash-Ksolves/kkube-task.git
    cd kkube-task
    ```

2. **Terraform Setup:**

    Initialize Terraform, plan, and apply changes:

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

3. **SSH into Bastion Node:**

    Use the AWS connect- `SSH client` to SSH into the bastion node:

    ```bash
    ssh -i "Yash-kube.pem" ec2-user@<public-dns-of-bastion-node>
    ```

4. **After successful SSH, Change Directory and Permissions:**

    ```bash
    cd ansible-playbook
    sudo chmod 600 Yash-kube.pem
    ```

5. **Update Hosts File:**

    Replace the public IP of both the `master and worker` instances in the `hosts` file.

6. **Check Connectivity:**

    Verify connectivity to all hosts using Ansible:

    ```bash
    ansible all -m ping -i hosts
    ```
    Insert `yes` for all prompts. If it still does not connect, first try making an SSH connection with both the master and worker using the AWS connect `SSH
    client`.


7. **Create Kubernetes Cluster:**

    Run the Ansible playbook to set up the Kubernetes cluster:

    ```bash
    ansible-playbook settingup_kubernetes_cluster.yml -i hosts -b
    ````

8. **SSH into Master-Worker:**

    SSH into the master-worker node for further configuration:

    ```bash
    ssh ec2-user@<public-ip-master-or-worker-nodes> -i Yash-kube.pem
    sudo -i  # Switch to root for Kubernetes commands
    ```
**Please review and suggest any needed changes.**
