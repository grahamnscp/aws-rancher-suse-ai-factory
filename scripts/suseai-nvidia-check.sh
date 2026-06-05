#!/bin/bash

source ./params.sh
source ./utils/utils.sh
source ./utils/load-tf-output.sh

AAGENTIP=${SUSEAI_PUBLIC_IP}
AAGENTNAME=${SUSEAI_NAME}
AAGENTN=$(echo $AAGENTNAME | cut -d. -f1)

#--------------------------------------------------------------------------------
# functions:

function checkagentx
{
  ssh $SSH_OPTS ${SSH_USERNAME}@${AAGENTIP} "sudo dmesg | egrep 'nvidia|nouveau'"
  ssh $SSH_OPTS ${SSH_USERNAME}@${AAGENTIP} "sudo lsmod | egrep 'nvidia|nouveau'"
  ssh $SSH_OPTS ${SSH_USERNAME}@${AAGENTIP} "sudo nvidia-smi"
}

# -------------------------------------------------------------------------------------
# Main
#
Log "Checking suseai gpu node ready (looping until instance up).."

while true
do
  CONFIGRAN=`ssh $SSH_OPTS ${SSH_USERNAME}@${AAGENTIP} "sudo ls -a /root/.suse-fb-config.ran 2>/dev/null | wc -l"`
  if [ "$CONFIGRAN" != "1" ]
  then
    echo -n "."
    sleep 10
    continue
  else
    checkagentx
  fi
  break
done

LogCompleted "Done."
# -------------------------------------------------------------------------------------

# tidy up
exit 0
