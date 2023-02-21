# hadolint ignore=DL3007
FROM myoung34/github-runner-base:ubuntu-jammy
LABEL maintainer="austin@sansterbioanalytics.com"
ARG GH_RUNNER_VERSION="2.302.1"
ARG R_VERSION="4.2.2"
ARG TARGETPLATFORM

#### BRANCH-SPECIFIC LABELS ####
# LABEL org.opencontainers.image.description DESCRIPTION
LABEL org.opencontainers.image.source = "https://github.com/sansterbioanalytics/docker-github-actions-runner/tree/r-4.2.2"
LABEL org.opencontainers.image.description="A CI/CD Ubuntu 22 based image configured for Github Actions, R 4.2.2, and a Devcontainer for VSCode (radian, renv, zsh)."

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

#### R ####
# Install R dependencies for related workloads
RUN apt-get update -y && apt-get install -y \
  build-essential libcurl4-openssl-dev gfortran liblapack-dev \
  libopenblas-dev libxml2-dev libpng-dev zlib1g-dev cmake \
  libreadline-dev libx11-dev libx11-doc default-jre default-jdk \
  libgdal-dev libproj-dev libgeos-dev libudunits2-dev libnode-dev libcairo2-dev libnetcdf-dev \
  libmagick++-dev libjq-dev libv8-dev libprotobuf-dev protobuf-compiler libsodium-dev imagemagick libgit2-dev \
  gobjc++ texinfo texlive-latex-base latex2html texlive-fonts-extra pandoc libharfbuzz-dev libfribidi-dev \
  fonts-urw-base35 libsdl-pango-dev xz-utils zsh zsh-common zsh-doc \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# Install R v4.2.2 from source with optimizations
RUN wget https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz && \
  tar -xvzf R-${R_VERSION}.tar.gz && \
  cd R-${R_VERSION} && \
  ./configure --with-blas="openblas" --with-lapack --enable-R-shlib  --prefix=/usr/bin/R-${R_VERSION} && \
  sudo make -j `nproc` && \
  sudo make install && \
  cd .. && \
  rm -rf R-${R_VERSION}.tar.gz ./R-${R_VERSION}

# Install core R development packages
RUN /usr/bin/R-${R_VERSION}/bin/Rscript -e 'install.packages(pkgs = c("renv", "xfun","lintr","jsonlite","httpgd","devtools","R6"), repos = "https://cloud.r-project.org")'
# Add related R development tools
RUN pip3 install radian

# Make sure R is in the path
ENV PATH="/usr/bin/R-${R_VERSION}/bin:${PATH}"

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

#### CODESPACES ####
# Setup the vscode user for codespaces
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && apt-get update \
  && apt-get install -y sudo wget less htop git build-essential curl \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  #
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*
# Setup zsh for vscode user
USER $USERNAME
ENV HOME /home/$USERNAME
RUN curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh -- \
  -p git \
  -p ssh-agent \
  -p poetry \
  -p https://github.com/zsh-users/zsh-autosuggestions \
  -p https://github.com/zsh-users/zsh-completions \
  -p https://github.com/zsh-users/zsh-syntax-highlighting

#### ACTIONS-RUNNER ####
USER root
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
