#!/bin/bash

source ./params.sh
source ./utils/utils.sh
source ./utils/load-tf-output.sh


Log "========> Performing SUSE AI Factory config on rancher.."

# registry secret for SUSE AIF SCC Subscription code
cat <<EOF | kubectl --kubeconfig=local/rancher-admin.conf apply -f -  > /dev/null 2>&1
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
cat <<EOF | kubectl --kubeconfig=./local/rancher-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: catalog.cattle.io/v1
kind: ClusterRepo
metadata:
  name: suse-aif-operator
  annotations:
    field.cattle.io/description: SUSE AIF Registry
spec:
  clientSecret:
    name: clusterrepo-auth-suseaifreg
    namespace: cattle-system
  insecurePlainHttp: false
  url: oci://ghcr.io/suse/chart/aif-operator
EOF

# cattle-ui-plugin-system - suse-aif-operator
# https://documentation.suse.com/suse-ai-factory/latest/html/AI-Factory-deployment/id-how-do-i-deploy-suse-ai-factory.html#ai-factory-deployment-rancher-ui
# https://github.com/SUSE/aif#extension-catalog-container

Log "Creating creating UI Extension Catalog and installing suse-ai-factory on rancher.."

# install operator
helm install --kubeconfig=./local/rancher-admin.conf aif-operator \
  oci://ghcr.io/suse/chart/aif-operator:${SUSE_AIF_OPERATOR_VERSION} \
  --namespace aif-operator --create-namespace

# --------------------
# SUSE AI Factory UI - Settings tab:
# SUSE Application Collection - secret in aif-operator namespace
cat <<EOF | kubectl --kubeconfig=local/rancher-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: v1
kind: Secret
metadata:
  name: clusterrepo-auth-suseappcol
  namespace: aif-operator
type: kubernetes.io/basic-auth
stringData:
  username: $APPCOL_USER
  password: $APPCOL_TOKEN
EOF

# SUSE AI Registry - secret in aif-operator namespace
cat <<EOF | kubectl --kubeconfig=local/rancher-admin.conf apply -f -  > /dev/null 2>&1
apiVersion: v1
kind: Secret
metadata:
  name: clusterrepo-auth-suseaireg
  namespace: aif-operator
type: kubernetes.io/basic-auth
stringData:
  username: regcode
  password: $SUSE_AIF_SUB
EOF


# --------------------

LogElapsedDuration
LogCompleted "Done."

# -------------------------------------------------------------------------------------

exit 0
