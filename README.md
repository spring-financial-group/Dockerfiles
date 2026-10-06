# Dockerfiles
Top-level container images used by MQube services.

## Adding a new container image
Say you want to add a new csharp image called `net-10`:
1. Create a folder within `dockerfiles/<category>/`, where the category best-describes the language or purpose of the image. The name of this sub-folder
will become the name of the generated image. Our `net-10` image would be created in `dockerfiles/csharp/net-10/`.
2. Regenerate the PR and release triggers in `.lighthouse/jenkins-x/triggers.yaml`:
```bash
./scripts/generate-triggers.sh
```
The `lint-pipelines` check fails if `triggers.yaml` is out of date, so don't edit it by hand.
3. (Optional) install `docksec` and `trivy` on your local machine, then run this script to add a `.docksec-ignore.yml` file to the new image folder:
```bash
./scripts/create-ignores.sh dockerfiles/csharp/net-10
```
This saves needing to get the results from the pipeline
4. Create a PR. The pipeline should run and build the new image