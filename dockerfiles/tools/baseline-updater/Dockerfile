# Runtime for the dockerfiles-baseline-updater CronJob (charts/dockerfiles-baseline-updater): the docksec image
# (docksec, trivy, docker CLI, yq) plus git and jq. The CronJob clones this repo and runs scripts/update-baselines-pr.sh,
# so the script isn't baked in here. The Docker daemon comes from a dind sidecar.
FROM jx3mqubebuild.azurecr.io/spring-financial-group/docksec:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends git jq \
    && rm -rf /var/lib/apt/lists/*

# The base image's built-in non-root user.
ENV HOME=/home/nonroot
USER 65532
WORKDIR /home/nonroot
