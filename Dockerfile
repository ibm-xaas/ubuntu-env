FROM ubuntu:22.04

ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME && \
	useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME

LABEL "maintainer"="SeungYeop Yang"
ENV WORKDIR=/ubuntu-env

ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/Central
# docker in docker
RUN set -ex && \
	apt-get update && \
	apt-get install -y ca-certificates gnupg lsb-release curl && \
	mkdir -m 0755 -p /etc/apt/keyrings && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
	apt-get update && \
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
# pyenv requires
RUN set -ex && \
	apt-get update && \
	apt-get install -y git build-essential libssl-dev zlib1g-dev \
	libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils \
	tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev sudo

RUN set -ex && \
	apt autoremove -y && \
	apt clean -y && \
	rm -rf /var/lib/apt/lists/*

RUN set -ex && \
	echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
	chmod 0440 /etc/sudoers.d/$USERNAME

# set environmental variables
USER $USERNAME
ENV HOME "/home/${USERNAME}"
ENV LC_ALL "C.UTF-8"
ENV LANG "en_US.UTF-8"

# pyenv
ENV PYENV_ROOT "${HOME}/.pyenv"
ENV PATH "${HOME}/.pyenv/shims:${HOME}/.pyenv/bin:${PATH}"
RUN echo 'eval "$(pyenv init -)"' >> ${HOME}/.bashrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> ${HOME}/.bashrc
#
# COPY requirements.txt ${HOME}/requirements.txt
#
RUN set -ex && \
	curl https://pyenv.run | bash && \
	pyenv install 3.10.5 && \
	pyenv global 3.10.5 && \
	pip install --upgrade pip && \
	# Ansible
	pip install ansible && \
	pip install pipenv && \
	pip install pre-commit
# pip install -r ${HOME}/requirements.txt && \
# rm ${HOME}/requirements.txt && \

# pylint
RUN set -ex && \
	cd ${HOME} && \
	pip install --upgrade pylint

# syft grype cli
RUN set -ex && \
	curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin && \
	curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin

# ubuntu 22.04 ssh rsa does not work for pakcer-provisioner-ansible; let's add temporary workaround
RUN set -ex && \
	echo '    PubkeyAcceptedKeyTypes +ssh-rsa' | sudo tee -a /etc/ssh/ssh_config && \
	echo '    HostKeyAlgorithms +ssh-rsa' | sudo tee -a /etc/ssh/ssh_config && \
	sudo usermod -aG docker ${USERNAME} && \
	sudo usermod -aG root ${USERNAME}

# ohmybash
RUN set -ex && \
	cd ${HOME} && \
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

WORKDIR $WORKDIR
