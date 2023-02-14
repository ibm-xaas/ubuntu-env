[![pre-commit](https://github.com/ibm-xaas/ubuntu-env/actions/workflows/pre-commit.yaml/badge.svg?branch=main)](https://github.com/ibm-xaas/ubuntu-env/actions/workflows/pre-commit.yaml)
[![Docker](https://github.com/ibm-xaas/ubuntu-env/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ibm-xaas/ubuntu-env/actions/workflows/docker-publish.yml)
[![@seungyeop's Holopin board](https://holopin.me/seungyeop)](https://holopin.io/@seungyeop)

# ubuntu-env
##
tested in macOS Ventura
Host:
- linux/amd64


## PREP

Please install the items below:
* docker
* docker-compose

## How to run
```
$ export IBMCLOUD_API_KEY=<YOUR IBMCLOUD_API_KEY>
$ docker-compose run ubuntu-env
```
## Available Tools
* ubuntu jammy (22.04) base
* docker-ce and docker-compose
* docker-in-docker
* pyenv, pipenv, Ansible latest
* python 3.10.5 or later
* pre-commit latest
* syft, grype latest
* ohmybash latest
