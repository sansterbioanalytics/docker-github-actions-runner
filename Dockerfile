# hadolint ignore=DL3007
FROM myoung34/github-runner-base:ubuntu-jammy
LABEL maintainer="austin@sansterbioanalytics.com"
ARG GH_RUNNER_VERSION="2.303.0"
ARG TARGETPLATFORM

#### BRANCH-SPECIFIC LABELS ####
LABEL org.opencontainers.image.source = "https://github.com/sansterbioanalytics/unified-actions-runner/tree/python-3.10"
LABEL org.opencontainers.image.description="A CI/CD Ubuntu 22 based image configured for Github Actions, Python 3.10, and Devcontainers. Includes Docker, Poetry, Pipx, and ZSH."

#### ACTIONS-RUNNER ####
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /actions-runner
COPY scripts/install_actions.sh /actions-runner

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh \
  && chown runner /_work /actions-runner /opt/hostedtoolcache

COPY scripts/token.sh scripts/entrypoint.sh scripts/app_token.sh /
RUN chmod +x /token.sh /entrypoint.sh /app_token.sh

#### PYTHON ####
# Install Python 3.10 and core dev requirements
RUN apt-get update && \
  apt-get install -y \
  python3 build-essential python3-pip python3.10-venv \
  python3-dev python3-apt python-is-python3

# Log Python Version
RUN python3 --version

# Install other system libraries for Python 
RUN apt-get update && \
  apt-get install -y \
  libcairo2-dev libjpeg-dev libgif-dev pkg-config libgirepository1.0-dev \
  libdbus-1-dev

# Install Poetry and Pipx
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/bin/poetry/ python3 -
RUN python3 -m pip install pipx

# Install mamba using pip
RUN wget -O Mambaforge.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh" \
  && bash Mambaforge.sh -b -f -p /usr/bin/conda \
  && source "/usr/bin/conda/etc/profile.d/conda.sh" \
  && conda activate \
  && source "/usr/bin/conda/etc/profile.d/mamba.sh"


# Add tools to path
RUN echo $PATH
ENV MAMBA_ROOT_PREFIX="/home/vscode/mamba"
ENV CONDA="/usr/bin/conda/bin/conda"
ENV PATH="/usr/bin/poetry/bin:${PATH}"
ENV PATH="/usr/bin/conda/bin:${PATH}"
RUN echo $PATH

# Ensure tools are installed
RUN poetry --version && pipx --version && conda --version && mamba --version

#### DOCKER ####
# Install Docker CE CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
  && sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable" \
  && sudo apt-get update \
  && sudo apt-get install -y docker-ce-cli \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

#### DEVCONTAINER ####
# Setup the vscode user for devcontainer
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && apt-get update \
  && apt-get install -y sudo wget less htop git build-essential curl zsh zsh-common zsh-doc \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  #
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# BUG /home/vscode/.zshrc:source:82: no such file or directory: /home/vscode/ohmyzsh/oh-my-zsh.sh
# Setup zsh for vscode user
USER $USERNAME
ENV HOME /home/$USERNAME
# Download using zsh-in-docker with desired extensions
RUN curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh -- \
  -p git \
  -p ssh-agent \
  -p poetry \
  -p https://github.com/zsh-users/zsh-autosuggestions \
  -p https://github.com/zsh-users/zsh-completions \
  -p https://github.com/zsh-users/zsh-syntax-highlighting


#### ACTIONS-RUNNER ####
USER root
# Resolve missing .oh-my.zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
