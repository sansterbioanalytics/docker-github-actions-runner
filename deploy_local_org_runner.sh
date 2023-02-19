#!/bin/bash

# Load in environmental variables
export $(grep -v '^#' .env | xargs)


#### BASH SCRIPT HELPERS ####

# Helper function to print out help messages
print_help() {
    echo "Usage: $0 [-h|--help] [-v|--version] RUNNER_GROUP"
    echo "Options:"
    echo "    -h, --help      Show this help message and exit"
    echo "    -v, --version   Show the version of this script and exit"
}

# Helper function to print out the version of the script
print_version() {
    echo "1.0.0"
}

# Validate user input
validate_input() {
    if [[ -z $1 ]]; then
        echo "Error: RUNNER_GROUP is a required argument."
        exit 1
    fi

    if [[ $1 != "master" && $1 != "dev" && != "r-4.2.2" && $1 != "python-3.10" ]]; then
        echo "Error: Invalid value for RUNNER_GROUP. Must be one of master, dev, r-4.2.2, or python-3.10"
        exit 1
    fi
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -v|--version)
            print_version
            exit 0
            ;;
        *)
            if [[ -z $runner_group ]]; then
                runner_group=$1
            else
                echo "Error: Unrecognized argument $1"
                exit 1
            fi
            ;;
    esac
    shift
done

start_runner(){
    case "$1" in
        r-4.2.2)
            image_name="ghcr.io/sansterbioanalytics/unified-actions-runner:r-4.2.2"
            ;;
        python3.10)
            image_name="ghcr.io/sansterbioanalytics/unified-actions-runner:python-3.10"
            ;;
        master)
            image_name="ghcr.io/sansterbioanalytics/unified-actions-runner:master"
            ;;
        dev)
            image_name="ghcr.io/sansterbioanalytics/unified-actions-runner:dev"
            ;;
        *)
            echo "Error: Invalid value for RUNNER_GROUP. Must be one of master, dev, r-4.2.2, or python-3.10."
            exit 1
    esac
    # Remove local runner if it already exists
    docker rm "github-runner-${runner_group,,}"
    # Start the runner
    docker run -d --restart always --name "github-runner-${runner_group,,}" \
      -e RUNNER_NAME_PREFIX="$RUNNER_NAME_PREFIX,${runner_group,,}"\
      -e ACCESS_TOKEN=$ACCESS_TOKEN \
      -e RUNNER_WORKDIR=$RUNNER_WORKDIR \
      -e RUNNER_GROUP=$RUNNER_GROUP \
      -e RUNNER_SCOPE=$RUNNER_SCOPE \
      -e DISABLE_AUTO_UPDATE=$DISABLE_AUTO_UPDATE \
      -e ORG_NAME=$ORG_NAME \
      -e LABELS="$LABELS,${runner_group,,}" \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /tmp/unified-actions-runner:/tmp/unified-actions-runner \
      $image_name
}

#### BEGIN RUNNER ####
validate_input $runner_group
echo "RUNNER_GROUP: $runner_group"

# Start the runner
start_runner $runner_group
