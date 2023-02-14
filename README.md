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

```
Seungs-MacBook-Pro:ubuntu-dev seungyeop$ docker-compose build
[+] Building 0.7s (18/18) FINISHED
 => [internal] load build definition from Dockerfile                                           0.0s
 => => transferring dockerfile: 32B                                                            0.0s
 => [internal] load .dockerignore                                                              0.0s
 => => transferring context: 2B                                                                0.0s
 => [internal] load metadata for docker.io/library/ubuntu:22.04                                0.6s
 => [ 1/14] FROM docker.io/library/ubuntu:22.04@sha256:9a0bdde4188b896a372804be2384015e90e3f8  0.0s
 => CACHED [ 2/14] RUN groupadd --gid 1000 ubuntu &&  useradd -s /bin/bash --uid 1000 --gid 1  0.0s
 ...
 => CACHED [14/14] WORKDIR /ubuntu-env                                                         0.0s
 => exporting to image                                                                         0.0s
 => => exporting layers                                                                        0.0s
 => => writing image sha256:a1bfb2e5d05514f0b747cef65928ccaa3348242c0d8ad73d3f0d6c00c9479ff6   0.0s
 => => naming to ghcr.io/ibm-xaas/ubuntu-env:main                                              0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
Seungs-MacBook-Pro:ubuntu-dev seungyeop$ docker-compose run ubuntu-env
04:40:49 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→ pre-commit install
pre-commit installed at .git/hooks/pre-commit
04:40:58 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→ git add *
04:41:08 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→ git status
On branch init
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   Dockerfile
        modified:   README.md
        modified:   docker-compose.yaml

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .github/workflows/docker-publish.yml
        modified:   .pre-commit-config.yaml

04:41:12 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→ git add .github/workflows/docker-publish.yml
04:41:22 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→ git add .pre-commit-config.yaml
04:41:30 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→ git commit -m "init"
[INFO] Initializing environment for https://github.com/pre-commit/pre-commit-hooks.
[INFO] Initializing environment for https://github.com/ibm/detect-secrets.
[INFO] Installing environment for https://github.com/pre-commit/pre-commit-hooks.
[INFO] Once installed this environment will be reused.
[INFO] This may take a few minutes...
[INFO] Installing environment for https://github.com/ibm/detect-secrets.
[INFO] Once installed this environment will be reused.
[INFO] This may take a few minutes...
trim trailing whitespace.................................................Passed
fix end of files.........................................................Passed
check yaml...............................................................Passed
check for added large files..............................................Passed
Detect secrets...........................................................Failed
- hook id: detect-secrets
- exit code: 3
- files were modified by this hook

The baseline file was updated.
Probably to keep line numbers of secrets up-to-date.
Please `git add .secrets.baseline`, thank you.

04:41:55 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→
04:42:38 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→ git add .secrets.baseline
04:42:45 ubuntu@576957a24aa2 ubuntu-env ±|init ✗|→ git commit -m "init"
trim trailing whitespace.................................................Passed
fix end of files.........................................................Passed
check yaml...............................................................Passed
check for added large files..............................................Passed
Detect secrets...........................................................Passed
[init 2db76a9] init
 6 files changed, 134 insertions(+), 451 deletions(-)
 rewrite Dockerfile (79%)
 rewrite README.md (90%)
04:42:51 ubuntu@576957a24aa2 ubuntu-env ±|init|→ pre-commit autoupdate
Updating https://github.com/pre-commit/pre-commit-hooks ... already up to date.
Updating https://github.com/ibm/detect-secrets ... already up to date.
04:43:03 ubuntu@576957a24aa2 ubuntu-env ±|init|→
```
