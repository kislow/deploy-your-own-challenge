# Ansible Playbook for assesment system

This playbook deploys docker, kind, some utils and sets up a kind cluster with nginx ingress controller.

## Prerequisite

- Ansible
- Python 3.8 or higher
- Optional: Virtual Envivonrment

## Setup ansible environment
```sh
python3 -m venv .venv
source .venv/bin/activate
pip install ansible python-docker
ansible-galaxy collection install pandemonium1986.k8s_toolbox
ansible-galaxy install geerlingguy.docker
ansible-galaxy install andrewrothstein.kind
```

### Quick start

```sh
export HOST=<IP>
ansible-playbook --diff -v -i $HOST, playbook.yaml --tags <TAG>
```

## Rollout
```sh
# the comma after $HOST is important!
$ ansible-playbook -i $HOST, playbook.yaml
```
## Roles/Tags
### base
The base tag will provision the base setup including a root password. The password will only be generated once and the stored in `/root/rootpw`.

### kind
Provisions a kind cluster with an nginx ingress controller.


### $rest
The rest are task specific roles, see below.

## Use tags to rollout specific tasks

**Note:** Tasks are located in ~/exercises/$TOPIC

```sh
# copy for go-docker-exercise to ~/challenge/go-application
$ ansible-playbook --diff -v -i $HOST, playbook.yaml --tags go-app

# to skip rollouts use --skip-tags
$ ansible-playbook --diff -v -i $HOST, playbook.yaml --skip-tags linux-curl
```
