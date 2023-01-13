# hadolint ignore=DL3007
FROM myoung34/github-runner-base:latest
LABEL maintainer="myoung34@my.apsu.edu"
LABEL forker="austin@sansterbioanalytics.com"
LABEL org.opencontainers.image.description="A CI/CD Ubuntu 22 based image with Python3.10 installed and configured for Github Actions"

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache

ARG GH_RUNNER_VERSION="2.300.2"
ARG PYTHON_VERSION="3.10.6"
ARG TARGETPLATFORM

#### ACTIONS-RUNNER ####

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /actions-runner
COPY install_actions.sh /actions-runner

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh \
  && chown runner /_work /actions-runner /opt/hostedtoolcache

COPY token.sh entrypoint.sh app_token.sh /
RUN chmod +x /token.sh /entrypoint.sh /app_token.sh

#### PYTHON ####

# Install Python 3.10, Poetry, Pipx
RUN apt-get update \
    && apt-get install -y \
    python3.10
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3.10
RUN python3.10 -m pip install pipx


#### CODESPACES ####

# Setup the vscode user for codespace
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo wget \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME
ENV HOME /home/$USERNAME
RUN cd ~ && sh -c "$(curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.1.4/zsh-in-docker.sh)" -- \
    -p git \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

#### ACTIONS-RUNNER ####

USER root
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]