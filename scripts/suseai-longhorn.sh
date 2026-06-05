#!/bin/bash

source ./params.sh
source ./utils/utils.sh
source ./utils/load-tf-output.sh

# -------------------------------------------------------------------------------------
# functions:

#
function longhornstoragescript
{
  Log "function longhornstoragescript:"

  cat << EOF >./local/longhorn-partition.sh
#!/bin/bash

VGNAME="vg_longhorn"
LVNAME="storage"
MOUNTPOINT="/var/lib/longhorn"

STORAGE_DEV=$STORAGE_DEV1

# Create a single partition for the whole disk
sfdisk /dev/\${STORAGE_DEV} <<- EOF1
label: gpt
type=linux
EOF1

# pause for a beat
sleep 2
partprobe

PARTITION="/dev/\${STORAGE_DEV}p1"

# Remove all the previous content (probably not needed)
wipefs --all \${PARTITION}

# Create a PV on top of the partition
lvm pvcreate \${PARTITION}

# Add it to the list of PVs so vgcreate can be easily executed
PVS+=" \${PARTITION}"

# Create a VG with all the PVs
lvm vgcreate \${VGNAME} \${PVS}

# A LV with all the free space, -Z is needed because there is no udev it seems
lvm lvcreate -Zn -l 100%FREE -n \${LVNAME} \${VGNAME}
mkfs.xfs /dev/mapper/\${VGNAME}-\${LVNAME}
mkdir -p \${MOUNTPOINT}
echo "/dev/mapper/\${VGNAME}-\${LVNAME} \${MOUNTPOINT} xfs noatime 0 0" >> /etc/fstab
mount \${MOUNTPOINT}

EOF
}

#
function mountlonghornstorage
{
  Log "function mountlonghornstorage"

  ANODEIP=${SUSEAI_PUBLIC_IP}
  APRIVATEIP=${SUSEAI_PRIVATE_IP}
  ANODENAME=${SUSEAI_NAME}
  ANODEN=$(echo $ANODENAME | cut -d. -f1)

  Log "\__Partitioning storage disk on node $ANODENAME"

  scp $SSH_OPTS ./local/longhorn-partition.sh ${SSH_USERNAME}@${ANODEIP}:~/
  ssh $SSH_OPTS ${SSH_USERNAME}@${ANODEIP} "sudo chmod +x ~/longhorn-partition.sh"
  ssh $SSH_OPTS ${SSH_USERNAME}@${ANODEIP} "sudo ~/longhorn-partition.sh 2>&1 > ~/longhorn-partition.log 2>&1"
}

#
function helminstalllonghorn
{
  Log "function helminstalllonghorn:"

  # create namespace
  kubectl --kubeconfig=./local/suseai-admin.conf create namespace longhorn-system

  # helm install longhorn
  helm repo add longhorn https://charts.longhorn.io
  helm repo update

  Log " \_Creating longhorn helm chart values.."
  cat << LEOF >./local/longhorn-values.yaml
defaultSettings:
  defaultReplicaCount: 1
persistence:
  defaultClass: true
  defaultFsType: xfs
  defaultClassReplicaCount: 1
LEOF

  Log " \_Installing longhorn helm chart.."
  helm upgrade --kubeconfig=./local/suseai-admin.conf \
    --install longhorn longhorn/longhorn \
    --namespace longhorn-system \
    -f ./local/longhorn-values.yaml \
    --timeout=5m

  Log " \_Waiting for longhorn chart rollout.."
  kubectl --kubeconfig=./local/suseai-admin.conf \
    wait pods -n longhorn-system \
    -l app.kubernetes.io/instance=longhorn --for condition=Ready \
    --timeout=300s
}


# -------------------------------------------------------------------------------------
# Main
LogStarted "Installing Longhorn on suseai.."

Log "\__Generating longhorn storage script.."
# generate partitioning script
longhornstoragescript

Log "\__Mounting longhorn volume on suseai.."
mountlonghornstorage
LogElapsedDuration

Log "\__Installing longhorn on suseai via helm.."
helminstalllonghorn

# -------------------------------------------------------------------------------------

# tidy up
exit 0
