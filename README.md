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
3. Add an empty `.docksec-ignore.yml` (`ignores: []`) and generate the image's `.docksec-baseline.json`. Install `docksec`,
`trivy` and Docker locally, then build and scan the new image:
```bash
./scripts/create-baselines.sh --build --trivydb dockerfiles/csharp/net-10
```
Without a baseline, the PR gate fails on every existing High/Critical finding in the image.
4. Create a PR. The pipeline should run and build the new image

## Image Publication Diagrams

Note: The following is a work-in-progress, and may not reflect the current state of the pipelines.

### Overview of Vulnerability Management
This is an overview of how the components work together to manage security findings from this repo to the end-service.

**TL;DR**
1. A daily cronjob opens a PR so every image is re-scanned against the latest Trivy DB.
2. The PR pipeline fails on any new High/Critical finding. The infra team fixes what it can and accepts the rest in `.docksec-ignore.yml`.
3. Merging releases the images to ACR, each signed and carrying its SBOM and full CVE report as attestations.
4. Services built on these images compare their own findings against the base image's attestation, so they're only blocked by findings they introduced or that nobody has accepted.

```mermaid
flowchart LR
    DB[("<b>Trivy DB</b><br/><small>trivydb:latest, updated daily</small>")] -.-> PR

    subgraph REPO["This repo"]
        direction LR
        CRON["<b>Run daily cronjob</b><br/><small>MDO opens a PR</small>"] --> PR["<b>Gate findings</b><br/><small>PR pipeline<br/>docksec ... --fail-on high</small>"]
        PR --> TRIAGE["<b>Fix or accept</b><br/><small>Dockerfile change or<br/>.docksec-ignore.yml</small>"]
        TRIAGE --> REL["<b>Publish image</b><br/><small>release pipeline<br/>sign + attest SBOM and CVE report</small>"]
    end

    REL --> ACR[("<b>ACR</b><br/><small>base image + signature<br/>+ attestations</small>")]

    subgraph SVC["Downstream service"]
        direction LR
        BUILD["<b>Build and scan</b><br/><small>FROM base image<br/>docksec ... --sbom</small>"] --> MQSEC["<b>Compare with base</b><br/><small>mqsec report ... --fail</small>"]
        MQSEC --> SHIP["<b>Push and sign</b><br/><small>only if no new or<br/>untriaged findings</small>"]
    end

    ACR -.->|Base image| BUILD
    ACR -.->|Accepted findings| MQSEC
```

### Updating CVE Findings
Trivy is used under-the-hood to scan images for vulnerabilities.
The trivy db is fetched from `ghcr.io/jenkins-x/trivydb:latest`, which is updated daily (starts at 6am UTC but takes ~6 hours to complete).
A cronjob runs daily to open a PR in this repo, which triggers all PR pipelines and updates the findings. 

```mermaid
flowchart LR
    V1["<b>Run daily cronjob</b><br/><small>MDO</small>"] --> V2["<b>Open PR</b><br/><small>runs every PR pipeline with<br/>trivydb:latest</small>"]
    V2 --> V3["<b>Analyse findings</b><br/><small>infra team</small>"]
    V3 --> V4["<b>Fix what we can</b><br/><small>update Dockerfiles</small>"]
    V3 --> V5["<b>Accept the rest</b><br/><small>add to .docksec-ignore.yml</small>"]
    V4 --> V6["<b>Merge PR</b><br/><small>release pipelines publish<br/>updated build images</small>"]
    V5 --> V6
```

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

### Baseline refresh (`update-baselines.yaml`)
A manually triggered pipeline: comment `/test update-baselines` on any PR. Whichever PR it's run from, it always
refreshes `main`'s baselines. It's plain Tekton, one task per step, sharing a workspace:

1. **`git-clone`** clones `main` once and extracts one `trivydb:latest` snapshot, so every image is scanned against
   the same DB.
2. **`scan-<image>`**, one task per image, all in parallel, each with its own `docker:dind` sidecar, runs
   `scripts/create-baselines.sh --trivydb <image-dir>` against the published `:latest` image
   (`docksec ... --update-baseline`, no gate, no build, no push).
3. **`commit-baselines`** runs `scripts/update-baselines-pr.sh`: if any `.docksec-baseline.json` changed, it makes one
   commit with just those files, force-pushes it to `chore/update-docksec-baselines` and opens or updates a PR. If
   nothing changed, any open baseline PR is closed as stale.

The PR body lists the fingerprints added and removed for each image. The PR isn't auto-merged: merging accepts the
added findings, so review them first. The baseline changes trigger the per-image PR pipelines, which gate against the
new baselines.

If an image fails to pull or scan, its baseline is left alone, it's listed in the PR body and `commit-baselines` is
marked failed. The other images are still updated. If a scan *pod* dies (eviction, OOM), Tekton skips
`commit-baselines`, so rerun the pipeline.

- **Generated:** `scripts/generate-triggers.sh` writes `update-baselines.yaml` (one scan task per
  `dockerfiles/<group>/<image>`) and its trigger. `lint-pipelines` fails if either is stale.
- **Image:** the scan tasks use `dockerfiles/tools/baseline-updater` (the docksec image plus git and jq).
- **Run it locally:** `scripts/create-baselines.sh --trivydb --all && DRY_RUN=true scripts/update-baselines-pr.sh`
  rescans everything and prints the PR body without pushing. `scripts/create-baselines.sh` also refreshes a single image.

```mermaid
flowchart LR
    U0["<b>/test update-baselines</b><br/><small>on any PR</small>"] --> U1["<b>Clone main</b><br/><small>+ trivydb snapshot</small>"]
    U1 --> U2["<b>scan-&lt;image&gt; x N</b><br/><small>parallel, :latest, dind sidecar<br/>docksec ... --update-baseline</small>"]
    U2 --> U6["<b>commit-baselines</b><br/><small>one commit</small>"]
    U6 -->|Baselines changed| U3["<b>Open/update PR</b><br/><small>baseline JSON only<br/>chore/update-docksec-baselines</small>"]
    U6 -->|No change| U5["<b>Close stale PR</b>"]
    U3 -.->|Triggers| P["<b>Per-image PR pipelines</b>"]
    U3 --> U4["<b>Review + merge</b><br/><small>infra team</small>"]
```

### Release pipeline (`dockerfile-release.yaml`)
Runs on merge to `main`. Scans without the ignore file and attaches the full CVE report and SBOM to the image as a signed attestations.

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
