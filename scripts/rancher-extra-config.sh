#!/bin/bash

source ./params.sh
source ./utils/utils.sh
source ./utils/load-tf-output.sh


Log "========> Performing extra config on rancher.."

# Add application-collection repo
Log "Creating application-collection clusterrepo on rancher.."

# secret
cat <<EOF | kubectl --kubeconfig=local/rancher-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: v1
kind: Secret
metadata:
  name: clusterrepo-auth-suseappcol
  namespace: cattle-system
type: kubernetes.io/basic-auth
stringData:
  username: $APPCOL_USER
  password: $APPCOL_TOKEN
EOF

# clusterrepo
cat <<EOF | kubectl --kubeconfig=local/rancher-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: catalog.cattle.io/v1
kind: ClusterRepo
metadata:
  name: application-collection
  annotations:
    field.cattle.io/description: SUSE Application Collection
spec:
  clientSecret:
    name: clusterrepo-auth-suseappcol
    namespace: cattle-system
  insecurePlainHttp: false
  url: oci://dp.apps.rancher.io/charts
EOF

LogElapsedDuration
LogCompleted "Done."

# -------------------------------------------------------------------------------------

exit 0
