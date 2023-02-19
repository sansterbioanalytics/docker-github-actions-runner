Unified Actions Runner
============================
[![Publish master Docker Image](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-master.yml/badge.svg?branch=master)](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-master.yml)
[![Publish dev Docker Image](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-dev.yml/badge.svg?branch=dev)](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-dev.yml)
[![Publish python 3.10 Docker Image](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-python-3.10.yml/badge.svg?branch=python-3.10)](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-python-3.10.yml)
[![Publish r-4.2.2 Docker Image](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-r-4.2.2.yml/badge.svg?branch=r-4.2.2)](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-r-4.2.2.yml)
## Introduction and Overview

Welcome to Sanster Bio Analytics' first open-source project, Unified Actions Runner.

This project is a fork of [myoung34/docker-github-actions-runner](https://github.com/myoung34/docker-github-actions-runner), but diverged to a point that I felt it represented a different idea. After I started playing with GitHub Actions, I knew I was hooked. It scratched my itch of minecraft-esque automations but with CI/CD. This project aims to create harmony between developer environments via Devcontainers and the underlying ability of Github Action workflows to build automated tests, linting, etc.

## Quickstart
### Deploy a local Organization-level Runner

This script assumes that you have the Docker CLI installed 

```bash
git clone https://github.com/sansterbioanalytics/unified-actions-runner
cd unified-actions-runner
nano .env # Fill out required env variables
./deploy_local_org_runner.sh `master` | `dev` | `r-4.2.2` | `python-3.10`
```

### Use within existing devcontainer.json files

If you already are operating within the devcontainer framework, simply change the image parameter.

`devcontainer.json`
```
// Using the same image as the actions runner for seamless renv and dependencies
"image": "ghcr.io/sansterbioanalytics/unified-actions-runner:r-4.2.2",
```

## Wiki
Please see [the wiki](https://github.com/sansterbioanalytics/unified-actions-runner/wiki/Home) for additional usage details.