#!/bin/bash

source ./params.sh
source ./utils/utils.sh
source ./utils/load-tf-output.sh

# --------------------------------------------------------------------
Log "Preparing for downstream cluster suseai general component deployment.."

# install cert manager
Log "\_Creating cert-manager namespace.."
kubectl --kubeconfig=./local/suseai-admin.conf create namespace cert-manager

Log "\_Creating application-collection secret for cert-manager.."
kubectl --kubeconfig=./local/suseai-admin.conf create secret docker-registry application-collection \
  --docker-server=dp.apps.rancher.io --docker-username=$APPCOL_USER --docker-password=$APPCOL_TOKEN \
  -n cert-manager

Log "\_Installing cert-manager on suseai.."
helm upgrade --kubeconfig=./local/suseai-admin.conf --install cert-manager \
  oci://dp.apps.rancher.io/charts/cert-manager \
  -n cert-manager \
  --timeout=5m \
  --set crds.enabled=true \
  --set global.imagePullSecrets={application-collection}

#  --set 'global.imagePullSecrets[0].name'=application-collection

# --------------------------------------------------------------------

LogCompleted "Done."

# tidy up
exit 0
