#!/bin/bash
export version=`curl -s https://github.com/aquasecurity/trivy-db/releases |  grep "tag" | sed -n 's/.*href="\([^"]*\).*/\1/p' | grep "tag" | grep "releases" | head -1 | cut -d "/" -f6`
wget https://github.com/aquasecurity/trivy-db/releases/download/${version}/trivy-offline.db.tgz
tar -xzvf trivy-offline.db.tgz
