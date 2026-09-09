#!/bin/bash

source ./params.sh
source ./utils/utils.sh
source ./utils/load-tf-output.sh

LogStarted "suseai factory config.."

# --------------------
Log "\__Adding application-collection ClusterRepo to AI cluster.."
# SUSE Application Collection - secret
cat <<EOF | kubectl --kubeconfig=./local/suseai-admin.conf apply -f -  > /dev/null 2>&1
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

# SUSE Application Collection - clusterrepo
cat <<EOF | kubectl --kubeconfig=./local/suseai-admin.conf apply -f -  > /dev/null 2>&1
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

# --------------------
# Add suse-ai-registry repo
Log "\__Adding suse-aif-registry ClusterRepo to AI cluster.."

# secret
cat <<EOF | kubectl --kubeconfig=./local/suseai-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: v1
kind: Secret
metadata:
  name: clusterrepo-auth-suseaifreg
  namespace: cattle-system
type: kubernetes.io/basic-auth
stringData:
  username: regcode
  password: ${SUSE_AIF_SUB}
EOF

# clusterrepo
cat <<EOF | kubectl --kubeconfig=./local/suseai-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: catalog.cattle.io/v1
kind: ClusterRepo
metadata:
  name: suse-aif-registry
  annotations:
    field.cattle.io/description: SUSE AIF Registry
spec:
  clientSecret:
    name: clusterrepo-auth-suseaifreg
    namespace: cattle-system
  insecurePlainHttp: false
  url: oci://ghcr.io/suse/chart/aif-operator
EOF

# --------------------
LogElapsedDuration
LogCompleted "Done."

# tidy up
exit 0

