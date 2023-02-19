# v1.0.0 Initial Release

Initial Release of Unified Action Runners with stable docker images for `r-4.2.2` and `python-3.10`

## Authors:
- This repository (`dev`, `r-4.2.2`, `python-3.10`) - Austin Hovland (austin@sansterbioanalytics.com)
- `fork` of docker-github-actions-runner - Marcus Young (7c8cty1esv2n@opayq.net)
## License:
MIT [License](../LICENSE)
## Global features
- `docker-ce-cli` Easily launch docker images no matter where you are
- `vscode` (sudo) user setup with basic necessities (`wget, less, htop, git, build-essential, curl`)
- `devcontainer` 
- `zsh` as default shell with autosuggestions, completions, and syntax highlighting

## Branch-specific features
- `master`
  - Stable base actions-runner and devcontainer environment. Production-level
- `dev`
  - Unstable actions-runner and devcontainer environment. Used to keep master stable :)
- `r-4.2.2`
  - `R` version 4.2.2 , built from source with optimizations (`openblas, lapack, R-shlib, even JAVA!`)
  - Literally every [system library](https://github.com/sansterbioanalytics/unified-actions-runner/blob/r-4.2.2/Dockerfile#L31) I could find for building R dependencies from source.
  - `renv` to handle package dependencies, with a *persistent shared cache* between containers and CI/CD workflows
  - `xfun, devtools` always good to have on hand
  - `radian, languageserver, lintr` for linting within vscode
  - `x11, latex, pdf` to handle all of your plotting library desires
- `python-3.10`
  - `Python` version 3.10.6 with a variety build requirements installed.
  - `pip, pipx, venv, mamba, poetry, libcairo` Your choice, but please use virtual environments.