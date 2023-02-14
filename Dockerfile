FROM ubuntu:22.04

ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME && \
	useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME

LABEL "maintainer"="SeungYeop Yang"
ENV WORKDIR=/dev-env

ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/Central
RUN set -ex && \
	apt-get update && \
	apt-get install -y \
	software-properties-common \
	tzdata \
	git \
	mercurial \
	build-essential \
	libssl-dev \
	libbz2-dev \
	zlib1g-dev \
	libffi-dev \
	libreadline-dev \
	libsqlite3-dev \
	curl \
	sudo \
	wget && \
	curl -fsSL https://apt.releases.hashicorp.com/gpg -o hashicorp.gpg && \
	sudo apt-key add hashicorp.gpg && \
	#sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
	sudo apt-add-repository "deb [arch=$(dpkg-architecture -q DEB_BUILD_ARCH)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
	apt-get update && \
	apt-get install -y \
	boundary \
	consul \
	#consul-k8s \
	vault \
	jq \
	vim \
	unzip \
	iputils-ping \
	dnsutils \
	qemu-utils \
	qemu \
	qemu-system \
	cloud-image-utils \
	graphviz \
	expect \
	nmap \
	traceroute \
	shelltestrunner \
	bats \
	pwgen \
	tcpdump && \
	apt-get upgrade -y \
	e2fsprogs \
	libgcrypt20 \
	libgnutls30 && \
	apt autoremove -y && \
	apt clean -y && \
	rm -rf /var/lib/apt/lists/* && \
	echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
	chmod 0440 /etc/sudoers.d/$USERNAME

# set environmental variables
USER $USERNAME
ENV HOME "/home/${USERNAME}"
ENV LC_ALL "C.UTF-8"
ENV LANG "en_US.UTF-8"

# # golang 1.18.3
RUN set -ex && \
	cd ${HOME} && \
	wget -q "https://dl.google.com/go/go1.18.3.linux-$(dpkg-architecture -q DEB_BUILD_ARCH).tar.gz" && \
	sudo tar -C /usr/local -xvzf "go1.18.3.linux-$(dpkg-architecture -q DEB_BUILD_ARCH).tar.gz" && \
	rm "go1.18.3.linux-$(dpkg-architecture -q DEB_BUILD_ARCH).tar.gz" && \
	mkdir -p ${HOME}/go && \
	sudo chown ${USER_UID}:${USER_GID} ${HOME}/go && \
	echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc
ENV PATH=$HOME/go/bin:/usr/local/go/bin:$PATH

# golangci-lint 1.44.0
RUN set -ex && \
	cd ${HOME} && \
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.44.0

# tfenv
RUN set -ex && \
	git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
	echo 'export PATH=$HOME/.tfenv/bin:$PATH' >> ~/.bashrc
ENV PATH=${HOME}/.tfenv/bin:$PATH
# tgenv
RUN set -ex && \
	git clone https://github.com/ibm-xaas/tgenv.git ~/.tgenv && \
	echo 'export PATH=$HOME/.tgenv/bin:$PATH' >> ~/.bashrc && \
	echo 'export TGENV_ARCH=$(dpkg-architecture -q DEB_BUILD_ARCH)' >> ~/.bashrc
ENV PATH=${HOME}/.tgenv/bin:$PATH
# pkenv
RUN set -ex && \
	git clone https://github.com/ibm-xaas/pkenv.git ~/.pkenv && \
	echo 'export PATH=$HOME/.pkenv/bin:$PATH' >> ~/.bashrc && \
	echo 'export PKENV_ARCH=$(dpkg-architecture -q DEB_BUILD_ARCH)' >> ~/.bashrc
ENV PATH=${HOME}/.pkenv/bin:$PATH

RUN set -ex && \
	cd ${HOME} && \
	tfenv install latest && \
	tgenv install latest && \
	pkenv install latest && \
	tfenv use latest && \
	tgenv use latest && \
	pkenv use latest

# ibmcloud cli client
# ibmcloud cli client installs docker
# docker-compose v2.8.0
RUN set -ex && \
	cd ${HOME} && \
	curl -sL https://ibm.biz/idt-installer | bash && \
	sudo curl -L "https://github.com/docker/compose/releases/download/v2.8.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
	sudo chmod +x /usr/local/bin/docker-compose && \
	ibmcloud plugin install --all -f || echo "this line can fail."

# pyenv
ENV PYENV_ROOT "${HOME}/.pyenv"
ENV PATH "${HOME}/.pyenv/shims:${HOME}/.pyenv/bin:${PATH}"
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
#
# COPY requirements.txt ${HOME}/requirements.txt
#
RUN set -ex && \
	curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash && \
	pyenv install 3.10.5 && \
	pyenv global 3.10.5 && \
	pip install --upgrade pip && \
	# Ansible
	pip install ansible && \
	pip install pipenv && \
	pip install pre-commit
# pip install -r ${HOME}/requirements.txt && \
# rm ${HOME}/requirements.txt && \

# install kubectl & helm v3
# kubectl was already installed probably from idt ks plugin
RUN set -ex && \
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN echo 'alias k="kubectl"' >> ~/.bashrc

RUN set -ex && \
	sudo curl -L "https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-$(dpkg-architecture -q DEB_BUILD_ARCH)" -o /usr/local/bin/goss && \
	sudo chmod +rx /usr/local/bin/goss && \
	cd ${HOME} && \
	mkdir -p ${HOME}/.packer.d/plugins && \
	cd ${HOME}/.packer.d/plugins && \
	# v3.1.3 for arm64
	wget -q "https://github.com/YaleUniversity/packer-provisioner-goss/releases/download/v3.1.3/packer-provisioner-goss-v3.1.3-linux-$(dpkg-architecture -q DEB_BUILD_ARCH).zip" && \
	unzip "packer-provisioner-goss-v3.1.3-linux-$(dpkg-architecture -q DEB_BUILD_ARCH).zip" && \
	rm -f "packer-provisioner-goss-v3.1.3-linux-$(dpkg-architecture -q DEB_BUILD_ARCH).zip"

# git@github.com:ibm-xaas/packer-provisioner-comment.git

RUN set -ex && \
	cd ${HOME} && \
	git clone https://github.com/ibm-xaas/packer-provisioner-comment.git && \
	cd packer-provisioner-comment && \
	#go mod init main && \
	go build && \
	mv main ${HOME}/.packer.d/plugins/packer-plugin-comment

# nvm and node
RUN set -ex && \
	cd ${HOME} && \
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

ENV NVM_DIR "${HOME}/.nvm"
# nvm and node
RUN set -ex && \
	cd ${HOME} && \
	. $NVM_DIR/nvm.sh && \
	nvm install --lts && \
	nvm use --lts && \
	npm install -g cdktf-cli@latest && \
	npm install -g typescript@latest && \
	# yarn latest
	npm install -g yarn@latest

# awscli v2
RUN set -ex && \
	cd ${HOME} && \
	curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
	unzip awscliv2.zip && \
	sudo ./aws/install && \
	rm -f awscliv2.zip

# azure cli
RUN set -ex && \
	cd ${HOME} && \
	curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# terraform-docs
RUN set -ex && \
	cd ${HOME} && \
	go install github.com/terraform-docs/terraform-docs@latest

# tfsec
RUN set -ex && \
	cd ${HOME} && \
	go install github.com/aquasecurity/tfsec/cmd/tfsec@latest

# terraform-linters
RUN set -ex && \
	cd ${HOME} && \
	curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# detect-secret
RUN set -ex && \
	cd ${HOME} && \
	pip install --upgrade "git+https://github.com/ibm/detect-secrets.git@master#egg=detect-secrets"

# envconsul
RUN set -ex && \
	cd ${HOME} && \
	go install github.com/hashicorp/envconsul@latest

# consul-template 0.29.0
RUN set -ex && \
	cd ${HOME} && \
	wget -q "https://releases.hashicorp.com/consul-template/0.29.0/consul-template_0.29.0_linux_$(dpkg-architecture -q DEB_BUILD_ARCH).zip" && \
	unzip "consul-template_0.29.0_linux_$(dpkg-architecture -q DEB_BUILD_ARCH).zip" && \
	sudo mv consul-template /usr/local/bin/consul-template && \
	sudo chmod +x /usr/local/bin/consul-template && \
	rm -f "consul-template_0.29.0_linux_$(dpkg-architecture -q DEB_BUILD_ARCH).zip"

# go pre-commit hook
RUN set -ex && \
	cd ${HOME} && \
	go install golang.org/x/lint/golint@latest && \
	go install golang.org/x/tools/cmd/goimports@latest && \
	go install github.com/fzipp/gocyclo/cmd/gocyclo@latest

# pylint
RUN set -ex && \
	cd ${HOME} && \
	pip install --upgrade pylint

# artifactory cli: jf
RUN set -ex && \
	cd ${HOME} && \
	curl -fL https://getcli.jfrog.io/v2-jf | sh && \
	sudo mv jf /usr/local/bin/

# syft cli
RUN set -ex && \
	curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin && \
	curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin

# ubuntu 22.04 ssh rsa does not work for pakcer-provisioner-ansible; let's add temporary workaround
RUN set -ex && \
	echo '    PubkeyAcceptedKeyTypes +ssh-rsa' | sudo tee -a /etc/ssh/ssh_config && \
	echo '    HostKeyAlgorithms +ssh-rsa' | sudo tee -a /etc/ssh/ssh_config && \
	sudo usermod -aG docker ${USERNAME} && \
	sudo usermod -aG boundary ${USERNAME} && \
	sudo usermod -aG root ${USERNAME}

# butane for Fedora CoreOS
RUN set -ex && \
  cd ${HOME} && \
	LATEST_BUTANE_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/coreos/butane/releases/latest | jq -r .tag_name) && \
	BUTANE_BINARY="butane-$(uname -m)-unknown-linux-gnu" &&\
	LATEST_BUTANE_ARTIFACT_URL="https://github.com/coreos/butane/releases/download/$LATEST_BUTANE_VERSION/$BUTANE_BINARY" && \
	wget $LATEST_BUTANE_ARTIFACT_URL && \
	sudo mv $BUTANE_BINARY /usr/local/bin/butane && \
	chmod +x /usr/local/bin/butane

# rust
RUN set -ex && \
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
	. ~/.profile

# tomlv
RUN set -ex && \
	cd ${HOME} && \
	go install github.com/BurntSushi/toml/cmd/tomlv@latest

# ohmybash
RUN set -ex && \
	cd ${HOME} && \
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

WORKDIR $WORKDIR
