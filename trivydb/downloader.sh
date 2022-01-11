#!/bin/bash
export version=`curl -s https://github.com/aquasecurity/trivy-db/releases/latest |  grep "tag" | sed -n 's/.*href="\([^"]*\).*/\1/p' | cut -d "/" -f8`
wget https://github.com/aquasecurity/trivy-db/releases/download/${version}/trivy-offline.db.tgz
tar -xzvf trivy-offline.db.tgz
