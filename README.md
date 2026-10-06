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

## Image Publication Diagrams

### PR pipeline (`dockerfile-pr.yaml`)
Gates the build: any High/Critical finding not listed in the image's `.docksec-ignore.yml` fails the PR.

```mermaid
flowchart LR
    P1["<b>Build image</b><br/><small>kaniko ... --no-push</small>"] --> P2["<b>Scan image</b><br/><small>docksec ... --ignore-file ... --fail-on high</small>"]
    P2 -->|High/Critical found| P3["<b>Alert security</b><br/><small>Slack #35;alerts-security</small>"]
    P2 --> P4{"<b>Unignored<br/>High/Critical?</b>"}
    P4 -->|Yes| P5["<b>Fail pipeline</b>"]
    P5 --> P6["<b>Fix or accept the vuln</b><br/><small>update .docksec-ignore.yml</small>"]
    P6 -.->|Re-run| P1
    P4 -->|No| P7["<b>Push and sign image</b><br/><small>crane push ... / cosign sign ...</small>"]
```

### Release pipeline (`dockerfile-release.yaml`)
Runs on merge to `main`. Scans without the ignore file and attaches the full CVE report and SBOM to the image as signed attestations.

```mermaid
flowchart LR
    R1["<b>Bump version</b><br/><small>jx-release-version</small>"] --> R2["<b>Build image</b><br/><small>kaniko ... --no-push</small>"]
    R2 --> R3["<b>Scan image</b><br/><small>docksec ... --sbom</small>"]
    R3 -->|High/Critical found| R4["<b>Alert security</b><br/><small>Slack #35;alerts-security</small>"]
    R3 --> R5["<b>Push and sign image</b><br/><small>crane push ... / cosign sign ...<br/>tags :VERSION + :latest</small>"]
    R5 --> R6["<b>Attest SBOM</b><br/><small>cosign attest --type cyclonedx ...</small>"]
    R6 --> R7["<b>Attest CVE report</b><br/><small>cosign attest --type .../scan-results/v1 ...</small>"]
    R7 --> ACR[("<b>ACR</b><br/><small>image + signature<br/>+ attestations</small>")]
```

### Downstream service pipeline (`build-scan-push-mqsec.yaml`)
**Note: At time of writing, this has not yet been implemented....**

Services built on one of these images use the `build-scan-push` task from `mqube-pipeline-catalog`. `mqsec report` checks each finding against the base image's signed attestation, so a service is only blocked by findings it introduced or that nobody has accepted.



```mermaid
flowchart LR
    S1["<b>Build image</b><br/><small>kaniko ... --no-push</small>"] --> S2["<b>Scan image</b><br/><small>docksec ... --sbom</small>"]
    S2 --> S3["<b>Compare with base image</b><br/><small>mqsec report ... --min-severity HIGH --fail</small>"]
    BASE[("<b>ACR base image</b><br/><small>last FROM + signed attestation</small>")] -.->|Accepted findings| S3
    S3 --> S4{"<b>Classify each<br/>HIGH+ finding</b>"}
    S4 -->|Base layers only,<br/>accepted by base| A["<b>INHERITED-ACCEPTED</b>"]
    S4 -->|Base layers only,<br/>not accepted| U["<b>INHERITED-UNTRIAGED</b>"]
    S4 -->|Layer added by<br/>this image| N["<b>NEW-IN-THIS-PR</b>"]
    A -->|If no other verdicts| S5["<b>Push and sign image</b><br/><small>crane push ... / cosign sign ...</small>"]
    U --> F["<b>Fail pipeline</b>"]
    N --> F
```
