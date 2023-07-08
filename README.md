# Deployment Proxmox LXC container using Ansible.
---
## Scenario description.
Fully automated Ansible deployment of LXC container (GitLab) inside Proxmox with using NFS server for some GitLab volumes attached to container (config, data, logs).
Deployment is done locally using VirtualBox 6.1 to host Proxmox. Proxmox 7.4 is used in scenario.
Debian 11 server is used for NFS storage. The server can be created inside Proxmox host or as a separate VM.
Network interface must be bridged and Promiscuous Mode set to Allow All.

### NFS server preparation.
NFS server configuration is not a part of automation scenario.
Here the steps to complete on Debian 11 to have NFS server installed.
- Install NFS server.
`apt install nfs-kernel-server rpcbind`
- Create shared folders for GitLab volumes. 
`mkdir -p /nfs/gitlab/config`
`mkdir /nfs/gitlab/data`
`mkdir /nfs/gitlab/logs`
- Edit exports file.
`nano /etc/exports`
- Add shared folders to the file.
`/nfs/gitlab/config    192.168.1.60(rw,sync,no_subtree_check,no_root_squash)`
`/nfs/gitlab/config    192.168.1.60(rw,sync,no_subtree_check,no_root_squash)`
`/nfs/gitlab/config    192.168.1.60(rw,sync,no_subtree_check,no_root_squash)`
- Restart and enable NFS service and check it is runnong.
`systemctl restart nfs-server`
`systemctl is-enabled nfs-server`
`systemctl status nfs-server`

### SSH key to connect the Proxmox host and LXC container.
In this lab scenarion same key is used for Proxmox host and LXC container.
To generate SSH key. Ed25519 algorithm is used in scenario.
`ssh-keygen -t ed25519`
Public key must be added to Proxmox authorized_keys file located at `/root/.ssh/authorized_keys`.
After that Proxmox host can be connected with SSH without password.

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
Ansible can be installed locally or using Python virtual environment.
In the lab local installation was used on workstation with Debian 11.
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
