# devcontainer.json

## `.devcontainer/devcontainer.json`

### R 4.2.2
```
// For format details, see https://aka.ms/devcontainer.json.
{
	"name": "Ubuntu - R 4.2.2",
	// Using the same image as the actions runner for seamless renv and dependencies
	"image": "ghcr.io/sansterbioanalytics/unified-actions-runner:r-4.2.2",
	"remoteUser": "vscode",
	// Features to add to the dev container. More info: https://containers.dev/features.
	"features": {
		// example "ghcr.io/rocker-org/devcontainer-features/your-desired-feature:0" : {},
	},
	"customizations": {
		"vscode": {
			"extensions": [
				"REditorSupport.r",
				"RDebugger.r-debugger"
			]
		}
	},
    // Optional, include an environment file injected into the devcontainer
	"runArgs": [
		"--env-file",
		".devcontainer/devcontainer.env"
	],
    // Required for proper permissions
	"remoteEnv": {
		"PATH": "${containerEnv:PATH}:/home/vscode/.local/bin"
	},
	// Use 'forwardPorts' to make a list of ports inside the container available locally.
	// "forwardPorts": [],
	// use 'initializeCommand' A command to run locally before anything else. This command is run before "onCreateCommand".
	// If this is a single string, it will be run in a shell. If this is an array of strings, it will be run as a single command without shell."
	// Use 'postCreateCommand' to run commands in the background inside the container after it is created.
	// Only runs once on creation.
    // Assumes a development environment with renv.lock present, shares cache with actions-runner.
	"postCreateCommand": "Rscript -e 'renv::activate();renv::restore()'"
	// Configure tool-specific properties.
	// "customizations": {},
}
```

## `.github/workflows/example.yaml`

```
# This is a basic workflow to help you get started with Actions

name: Build renv cache

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the "main" branch
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
	# Must match all LABELS in runner, excellent to provision runners with different envs
    runs-on: [self-hosted, Linux, r-4.2.2]
    env: 
      RENV_PATHS_ROOT: ~/.renv
    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      - name: Install and activate renv
        shell: Rscript {0}
        run: |
          renv::activate()
          renv::restore()
      # - uses: actions/checkout@v3
      - name: Restore Renv package cache
        uses: actions/cache@v3
        with:
          path: "~/.renv"
          key: ${{ runner.os }}-r_4.2.2-${{ inputs.cache-version }}-${{ hashFiles('renv.lock') }}
          restore-keys: ${{ runner.os }}-r_4.2.2-${{ inputs.cache-version }}-
```
