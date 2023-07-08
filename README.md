# Deployment Proxmox LXC container using Ansible.

---

## Scenario description.

Fully automated Ansible deployment of LXC container (GitLab) inside Proxmox with using NFS server for some GitLab volumes attached to container (config, data, logs).

Deployment is done locally using VirtualBox 6.1 to install Proxmox. Proxmox 7.4 ISO is used in scenario.

Create VirtualBox VM for proxmox.

VirtualBox system must have enabled **PAE/NX** and **VT-x/AMD-V** features.

Network interface must be bridged and Promiscuous Mode set to Allow All.

Proxmox host name in the scenario `pve-host`. If use different name change it in the `group_vars/all.yml` file.

Proxmox host IP address in the scenario is `192.168.1.50/24`. If you use different IP than do changes in `group_vars/all.yml` file.

Debian 11 server Proxmox VM is used for NFS storage. NFS Server IP in the scenario is `192.168.1.205/24`. You need to change this IP in `deploy_gitlab.yml` file if you different IP.

### NFS server preparation.

Here the steps to complete NFS server installation on Debian 11 proxmox VM.

- Install NFS server.

`apt install nfs-kernel-server rpcbind`

- Create shared folders for GitLab volumes.

`mkdir -p /nfs/gitlab/config`

`mkdir /nfs/gitlab/data`

`mkdir /nfs/gitlab/logs`

- Edit exports file.

`nano /etc/exports`

- Add shared folders to the file. Use IP address to planed GitLab LXC container. `192.168.1.60` in this scenario.

`/nfs/gitlab/config    192.168.1.60(rw,sync,no_subtree_check,no_root_squash)`

`/nfs/gitlab/config    192.168.1.60(rw,sync,no_subtree_check,no_root_squash)`

`/nfs/gitlab/config    192.168.1.60(rw,sync,no_subtree_check,no_root_squash)`

- Restart and enable NFS service and check it is runnong.

`systemctl restart nfs-server`

`systemctl is-enabled nfs-server`

`systemctl status nfs-server`

### SSH key to connect the Proxmox host and LXC container.

For machine to run ansible commands used Debian 11 LXC container.

Create container. It can have any IP inside `192.168.1.0/24` network to be able to communicate with the host. We need ssh keys to connect to running Proxmox host and to connect to LXC container we going to deploy.

In this lab scenario the same key is used for Proxmox host and planned for deployment LXC container.

To generate SSH key. Ed25519 algorithm is used.

`ssh-keygen -t ed25519`

Public key must be added to Proxmox host authorized_keys file located at `/root/.ssh/authorized_keys`.

After that Proxmox host can be connected with SSH without password.

Also replace public key in `group_vars/all.yml` file.

### Proxmoxer installation.

To send remote commands to Proxmox required to install Proxmoxer wrapper on the Proxmox host.

- First install pip.

`apt-get update && apt-get upgrade`

`apt install python3-pip`

- And install Proxmoxer with requirments.

`pip3 install proxmoxer`

`pip3 install requests`

`pip3 install paramiko`

`pip3 install openssh_wrapper`

### Ansible installation.

Ansible can be installed locally or using Python virtual environment. In the lab local installation was used on workstation with Debian 11 LXC container.

- Install dependencies.

`apt-get update && apt-get install gnupg2 curl wget -y`

- Edit source list.

`nano /etc/apt/sources.list`

- And add Ansible repo line.

`deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main`

- Add Ansible GPG key.

`apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367`

- Update packages cache and install Ansible.

`apt-get update && apt-get install ansible -y`

- Check the version.

`ansible --version`

### Ansible Proxmox modules

To be able to run ansible playbooks for Proxmox community.general module must be installed.

- To install use ansible-galaxy command.

`ansible-galaxy collection install community.general`

### Clone the repo

Install git.

`apt-get install git -y`

Clone repo.

`git clone https://github.com/IgorGrishko/Ansible_Proxmox_LXC_deployment.git`

Go to ansible directory.

`cd Ansible_Proxmox_LXC_deployment/ansible/`

### Start the deployment.

Export environment variables for passwords.

`export PROXMOX_PASSWORD="admin"`

`export CONTAINER_PASSWORD="secret"`

Stat playbook.

`ansible-playbook main.yml`

### Connection to GitLab

When deployment is completed use GitLab IP to connect. The IP address in the scenario is `192.168.1.60`.
