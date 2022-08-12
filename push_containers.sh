#!/bin/bash
set -e
source .jx/variables.sh
cp /tekton/creds-secrets/tekton-container-registry-auth/.dockerconfigjson ~/.docker/config.json

for image in $(find . -maxdepth 1 -type d | sed 's|^./||' | grep -F -v .); do
  echo -e "\n------------------ PUSHING CONTAINER $image ------------------\n"
  crane push /workspace/source/"$image".tar $PUSH_CONTAINER_REGISTRY/$DOCKER_REGISTRY_ORG/$image:$VERSION
  cosign sign --key k8s://jx-staging/cosign $PUSH_CONTAINER_REGISTRY/$DOCKER_REGISTRY_ORG/$image:$VERSION
  cosign verify --key k8s://jx-staging/cosign $PUSH_CONTAINER_REGISTRY/$DOCKER_REGISTRY_ORG/$image:$VERSION
done