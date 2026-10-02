# Dockerfiles
Top-level container images used by MQube services.

## Adding a new container image
Say you want to add a new csharp image called `net-10`:
1. Create a folder within `dockerfiles/<category>/`, where the category best-describes the language or purpose of the image. The name of this sub-folder
will become the name of the generated image. Our `net-10` image would be created in `dockerfiles/csharp/net-10/`.
2. Add a new PR and release triggers in `.lighthouse/jenkins-x/triggers.yaml`. In our example:
```yaml
apiVersion: config.lighthouse.jenkins-x.io/v1alpha1
kind: TriggerConfig
spec:
  presubmits:
....
  - name: net-10-pr
    optional: false
    run_if_changed: (README.md|^dockerfiles\/csharp\/net-10\/.*$)
    source: "dockerfile-pr.yaml"
    pipeline_run_params:
    - name: IMAGE_NAME
      value_template: net-10
    - name: IMAGE_DIR
      value_template: dockerfiles/csharp/net-10
....
postsubmits:
....
  - name: net-10-release
    source: "dockerfile-release.yaml"
    branches:
    - ^main$
    - ^master$
    pipeline_run_params:
    - name: IMAGE_NAME
      value_template: net-10
    - name: IMAGE_DIR
      value_template: dockerfiles/csharp/net-10
```
3. (Optional) install `docksec` and `trivy` on your local machine, then run this script to add a `.docksec-ignore.yml` file to the new image folder:
```bash
./scripts/add-docksec-ignore.sh dockerfiles/csharp/net-10
```
This saves needing to get the results from the pipeline
4. Create a PR. The pipeline should run and build the new image