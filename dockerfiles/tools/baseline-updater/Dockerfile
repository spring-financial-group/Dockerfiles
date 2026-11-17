# Runtime for the scan tasks of the update-baselines pipeline (.lighthouse/jenkins-x/update-baselines.yaml): the
# docksec image (docksec, trivy, docker CLI, yq) plus git and jq, for scripts/create-baselines.sh. The pipeline runs the
# scripts from its clone of the repo, so they aren't baked in here. The Docker daemon comes from a dind sidecar.
FROM jx3mqubebuild.azurecr.io/spring-financial-group/docksec:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends git jq \
    && rm -rf /var/lib/apt/lists/*

# The base image's built-in non-root user.
ENV HOME=/home/nonroot
USER 65532
WORKDIR /home/nonroot
