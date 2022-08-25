# Dockerfiles
Container images without high and critical vulnerabilities.

## Adding a new container image
To add a new container image create a new folder containing the new Dockerfile. The name of the folder will become the name 
of the image in the registry.

The PR pipeline will build the images for testing. On release the containers will be pushed to the registry.  
