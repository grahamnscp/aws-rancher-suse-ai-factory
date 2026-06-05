#!/bin/bash

source ./params.sh
source ./utils/utils.sh
source ./utils/load-tf-output.sh

LogStarted "Extra Config for suseai cluster.."

# Add ClusterRepos to AI cluster

# Add application-collection repo
Log "\__Adding application-collection ClusterRepo to AI cluster.."
# secret
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

# clusterrepo
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

# Add suse-ai-registry repo
Log "\__Adding suse-ai-registry ClusterRepo to AI cluster.."

# secret
cat <<EOF | kubectl --kubeconfig=./local/suseai-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: v1
kind: Secret
metadata:
  name: clusterrepo-auth-suseaireg
  namespace: cattle-system
type: kubernetes.io/basic-auth
stringData:
  username: regcode
  password: $SUSE_AI_SUB
EOF
# clusterrepo
cat <<EOF | kubectl --kubeconfig=./local/suseai-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: catalog.cattle.io/v1
kind: ClusterRepo
metadata:
  name: suse-ai-registry
  annotations:
    field.cattle.io/description: SUSE AI Registry
spec:
  clientSecret:
    name: clusterrepo-auth-suseaireg
    namespace: cattle-system
  insecurePlainHttp: false
  url: oci://registry.suse.com/ai/charts
EOF


LogElapsedDuration
LogCompleted "Done."

# tidy up
exit 0
