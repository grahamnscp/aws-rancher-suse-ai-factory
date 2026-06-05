# aws-rancher-suse-ai-lifecycle
Terraform and scripts to deploy rancher + single node GPU downstream cluster
  
deploy script calls sub scripts to install and configure the rancher manager cluster and prepare the downstream cluster suseai for SUSE AI Factory application deployment.  
  
The terraform userdata-suseai.sh installs the NVIDIA driver for SLES 15 SP7 and uses a onetime systemd script for extra config and reboot.  
  
The suseai ds cluster is registered to the Rancher Manager.  
  
Note: the scripts use local (desktop) apps; kubectl, helm, rancher cli  
  
You will need a SUSE Application Collection login and also a SCC SUSE AI entitlement.  
