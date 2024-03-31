
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
