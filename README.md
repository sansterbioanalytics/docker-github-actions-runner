Unified Actions Runner
============================
[![Publish master Docker Image](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-master.yml/badge.svg?branch=master)](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-master.yml)
[![Publish dev Docker Image](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-dev.yml/badge.svg?branch=dev)](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-dev.yml)
[![Publish python 3.10 Docker Image](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-python-3.10.yml/badge.svg?branch=python-3.10)](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-python-3.10.yml)
[![Publish r-4.2.2 Docker Image](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-r-4.2.2.yml/badge.svg?branch=r-4.2.2)](https://github.com/sansterbioanalytics/unified-actions-runner/actions/workflows/ghcr-publish-r-4.2.2.yml)

![Runner Versions](https://ghcr-badge.deta.dev/sansterbioanalytics/unified-actions-runner/tags?trim=major&ignore=sha256*)

## Introduction and Overview

Hello and welcome to my first real open-source project! 

## Deploy a local Organization-level Runner ##

This script assumes that you have the Docker CLI installed 

```bash
git clone https://github.com/sansterbioanalytics/unified-actions-runner
cd unified-actions-runner
nano .env # Fill out required env variables
./deploy_local_org_runner.sh `master` | `dev` | `r-4.2.2` | `python-3.10`
```

Please see [the wiki](https://github.com/sansterbioanalytics/unified-actions-runner/wiki/Home) for details on how to deploy unified action runners and more.


### Security ###

It is known that environment variables are not safe from exfiltration.
If you are using this runner make sure that any workflow changes are gated by a verification process (in the actions settings) so that malicious PR's cannot exfiltrate these.

### Docker Support ###

Please note that while this runner installs and allows docker, github actions itself does not support using docker from a self hosted runner yet.
For more information:

* https://github.com/actions/runner/issues/406
* https://github.com/actions/runner/issues/367

Also, some GitHub Actions Workflow features, like [Job Services](https://docs.github.com/en/actions/guides/about-service-containers), won't be usable and [will result in an error](https://github.com/myoung34/docker-github-actions-runner/issues/61).

### Containerd Support ###

Currently runners [do not support containerd](https://github.com/actions/runner/issues/1265)

### Docker-Compose on ARM ###

Please note `docker-compose` does not currently work on ARM ([see issue](https://github.com/docker/compose/issues/6831)) so it is not installed on ARM based builds here.
A workaround exists, please see [here](https://github.com/myoung34/docker-github-actions-runner/issues/72#issuecomment-804723656)

## Environment Variables ##

| Environment Variable | Description |
| --- | --- |
| `RUN_AS_ROOT` | Boolean to run as root. If `true`: will run as root. If `True` and the user is overridden it will error. If any other value it will run as the `runner` user and allow an optional override. Default is `true` |
| `RUNNER_NAME` | The name of the runner to use. Supercedes (overrides) `RUNNER_NAME_PREFIX` |
| `RUNNER_NAME_PREFIX` | A prefix for runner name (See `RANDOM_RUNNER_SUFFIX` for how the full name is generated). Note: will be overridden by `RUNNER_NAME` if provided. Defaults to `github-runner` |
| `RANDOM_RUNNER_SUFFIX` | Boolean to use a randomized runner name suffix (preceeded by `RUNNER_NAME_PREFIX`). Will use a 13 character random string by default. If set to a value other than true it will attempt to use the contents of `/etc/hostname` or fall back to a random string if the file does not exist or is empty. Note: will be overridden by `RUNNER_NAME` if provided. Defaults to `true`. |
| `ACCESS_TOKEN` | A [github PAT](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) to use to generate `RUNNER_TOKEN` dynamically at container start. Not using this requires a valid `RUNNER_TOKEN` |
| `APP_ID` | The github application ID. Must be paired with `APP_PRIVATE_KEY` and should not be used with `ACCESS_TOKEN` or `RUNNER_TOKEN` |
| `APP_PRIVATE_KEY` | The github application private key. Must be paired with `APP_ID` and should not be used with `ACCESS_TOKEN` or `RUNNER_TOKEN` |
| `APP_LOGIN` | The github application login id. Can be paired with `APP_ID` and `APP_PRIVATE_KEY` if default value extracted from `REPO_URL` or `ORG_NAME` is not correct. Note that no default is present when `RUNNER_SCOPE` is 'enterprise'. |
| `RUNNER_SCOPE` | The scope the runner will be registered on. Valid values are `repo`, `org` and `ent`. For 'org' and 'enterprise', `ACCESS_TOKEN` is required and `REPO_URL` is unnecessary. If 'org', requires `ORG_NAME`; if 'enterprise', requires `ENTERPRISE_NAME`. Default is 'repo'. |
| `ORG_NAME` | The organization name for the runner to register under. Requires `RUNNER_SCOPE` to be 'org'. No default value. |
| `ENTERPRISE_NAME` | The enterprise name for the runner to register under. Requires `RUNNER_SCOPE` to be 'enterprise'. No default value. |
| `LABELS` | A comma separated string to indicate the labels. Default is 'default' |
| `REPO_URL` | If using a non-organization runner this is the full repository url to register under such as 'https://github.com/myoung34/repo' |
| `RUNNER_TOKEN` | If not using a PAT for `ACCESS_TOKEN` this will be the runner token provided by the Add Runner UI (a manual process). Note: This token is short lived and will change frequently. `ACCESS_TOKEN` is likely preferred. |
| `RUNNER_WORKDIR` | The working directory for the runner. Runners on the same host should not share this directory. Default is '/_work'. This must match the source path for the bind-mounted volume at RUNNER_WORKDIR, in order for container actions to access files. |
| `RUNNER_GROUP` | Name of the runner group to add this runner to (defaults to the default runner group) |
| `GITHUB_HOST` | Optional URL of the Github Enterprise server e.g github.mycompany.com. Defaults to `github.com`. |
| `DISABLE_AUTOMATIC_DEREGISTRATION` | Optional flag to disable signal catching for deregistration. Default is `false`. Any value other than exactly `false` is considered `true`. See [here](https://github.com/myoung34/docker-github-actions-runner/issues/94) |
| `CONFIGURED_ACTIONS_RUNNER_FILES_DIR` | Path to use for runner data. It allows avoiding reregistration each the start of the runner. No default value. |
| `EPHEMERAL` | Optional flag to configure runner with [`--ephemeral` option](https://docs.github.com/en/actions/hosting-your-own-runners/autoscaling-with-self-hosted-runners#using-ephemeral-runners-for-autoscaling). Ephemeral runners are suitable for autoscaling. |
| `DISABLE_AUTO_UPDATE` | Optional environment variable to [disable auto updates](https://github.blog/changelog/2022-02-01-github-actions-self-hosted-runners-can-now-disable-automatic-updates/). Auto updates are enabled by default to preserve past behavior. Any value is considered truthy and will disable them. |
