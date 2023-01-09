# Load in environmental variables
export $(grep -v '^#' .env | xargs)

# Login to ghrc
echo $CLASSIC_ACCESS_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# Pull the image
docker pull ghcr.io/sansterbioanalytics/docker-github-actions-runner:master

#BUG pat is not allowed to gain access to the packages?
#TODO make this fully emphemeral to save disk space
#TODO make this mount a volume with a local cache.
#TODO Update local cache and propogate this to codespaces?

# Start the runner
docker run -d --restart always --name github-runner \
  -e RUNNER_NAME_PREFIX=$RUNNER_NAME_PREFIX \
  -e ACCESS_TOKEN=$ACCESS_TOKEN \
  -e RUNNER_WORKDIR=$RUNNER_WORKDIR \
  -e RUNNER_GROUP=$RUNNER_GROUP \
  -e RUNNER_SCOPE=$RUNNER_SCOPE \
  -e DISABLE_AUTO_UPDATE=$DISABLE_AUTO_UPDATE \
  -e ORG_NAME=$ORG_NAME \
  -e LABELS=$LABELS \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/sansterbioanalytics/docker-github-actions-runner:/tmp/sansterbioanalytics/docker-github-actions-runner \
  ghcr.io/sansterbioanalytics/docker-github-actions-runner:master