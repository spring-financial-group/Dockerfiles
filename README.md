# Dockerfiles
Top level container images used in MQube services. We should probably get rid of these and use image caching layers instead.

## Adding a new container image
1. Create a folder containing the Dockerfile you wish to use in the root of the repository. The name of this folder
will become the name of the generated image.
2. In `/.lighthouse/jenkins-x/` copy one of the existing folders and rename it to the name of image.
3. Change the environment variable `IMAGE_NAME` in `pr.yaml` & `release.yaml` to be the name of the image.
4. Open a PR with your changes.

