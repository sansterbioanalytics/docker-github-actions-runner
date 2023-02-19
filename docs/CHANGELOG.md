# v1.0.0 Initial Release

Initial Release of Unified Action Runners with stable docker images for `r-4.2.2` and `python-3.10`

## Global features
- `docker-ce-cli` Easily launch docker images no matter where you are
- `vscode` (sudo) user setup with basic necessities (`wget, less, htop, git, build-essential, curl`)
- `zsh` as default shell with autosuggestions, completions, and syntax highlighting

## Branch-specific features
- `master`
  - Stable base actions-runner and devcontainer environment. Production-level
- `dev`
  - Unstable actions-runner and devcontainer environment. Used to keep master stable :)
- `r-4.2.2`
  - `R` version 4.2.2 , built from source with optimizations (`openblas, lapack, R-shlib, pdf, xfun, lintr, devtools, even JAVA!`)
  - `radian` for linting within vscode
  - `renv` to handle package dependencies, with a *persistent, shared cache* in workflows and containers
- `python-3.10`
  - `Python` version 3.10.6 with a variety build requirements installed.
  - `pip, pipx, venv, mamba, poetry, libcairo` Your choice, but please use virtual environments.