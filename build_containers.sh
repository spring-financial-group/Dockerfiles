#!/busybox/sh
set -e
source .jx/variables.sh
cp /tekton/creds-secrets/tekton-container-registry-auth/.dockerconfigjson /kaniko/.docker/config.json

for image in $(find . -maxdepth 1 -type d | sed 's|^./||' | grep -F -v .); do
  echo -e "\n------------------ BUILDING CONTAINER $image ------------------\n"
  /kaniko/executor $KANIKO_FLAGS --cleanup --context=/workspace/source/$image --dockerfile="Dockerfile" --destination=$PUSH_CONTAINER_REGISTRY/$DOCKER_REGISTRY_ORG/$image:$VERSION --no-push --tarPath "$image".tar
done