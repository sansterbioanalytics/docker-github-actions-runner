
FROM myoung34/github-runner-base:ubuntu-jammy
LABEL maintainer="myoung34@my.apsu.edu"
LABEL forker="austin@sansterbioanalytics.com"
LABEL org.opencontainers.image.description="A CI/CD Ubuntu 22 based image with R-4.2.2 installed and configured for Github Actions"

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache

ARG GH_RUNNER_VERSION="2.300.2"
ARG R_VERSION="4.2.2"
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /actions-runner
COPY install_actions.sh /actions-runner

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh \
  && chown runner /_work /actions-runner /opt/hostedtoolcache

COPY token.sh entrypoint.sh app_token.sh /
RUN chmod +x /token.sh /entrypoint.sh /app_token.sh

# Install R dependencies for related workloads
RUN apt-get update -y && apt-get install -y \
build-essential libcurl4-openssl-dev gfortran liblapack-dev \
libopenblas-dev libxml2-dev libpng-dev zlib1g-dev cmake \
libreadline-dev libx11-dev libx11-doc \
libgdal-dev libproj-dev libgeos-dev libudunits2-dev libnode-dev libcairo2-dev libnetcdf-dev \
libmagick++-dev libjq-dev libv8-dev libprotobuf-dev protobuf-compiler libsodium-dev imagemagick libgit2-dev \
gobjc++ texinfo texlive-latex-base latex2html texlive-fonts-extra

# Install java? (currently not implemented)
#15 198.6 make[1]: Entering directory '/actions-runner/R-4.2.2'
#15 198.6 configuring Java ...
#15 198.7 
#15 198.7 *** Cannot find any Java interpreter
#15 198.7 *** Please make sure 'java' is on your PATH or set JAVA_HOME correspondingly
#15 198.7 make[1]: [Makefile:87: stamp-java] Error 1 (ignored)

# Install R v4.2.2 from source
RUN wget https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz && tar -xvzf R-${R_VERSION}.tar.gz && cd R-${R_VERSION} && ./configure --with-blas="openblas" --with-lapack && sudo make -j`nproc` && sudo make install
RUN Rscript -e 'install.packages(pkgs = c("renv", "xfun"), repos = "https://cloud.r-project.org")'

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

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.4/zsh-in-docker.sh)"

COPY zsh-in-docker.sh /tmp

RUN /tmp/zsh-in-docker.sh \
    -p git \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
