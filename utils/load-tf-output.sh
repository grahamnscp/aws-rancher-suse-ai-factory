#/bin/bash -x

source ./params.sh
source ./utils/utils.sh

TMP_FILE=/tmp/load-tf-output.tmp.$$

Log "Collecting terraform output values.."

# Collect node details from terraform output
CWD=`pwd`
cd tf
terraform output > $TMP_FILE
cd $CWD

# Some parsing into shell variables and arrays
DATA=`cat $TMP_FILE |sed "s/'//g"|sed 's/\ =\ /=/g'`
DATA2=`echo $DATA |sed 's/\ *\[/\[/g'|sed 's/\[\ */\[/g'|sed 's/\ *\]/\]/g'|sed 's/\,\ */\,/g'`

for var in `echo $DATA2`
do
  var_name=`echo $var | awk -F"=" '{print $1}'`
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g' |sed 's/\"//g'`
  #echo TF_OUTPUT: $var_name: $var_value

  case $var_name in

    "domainname")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        DOMAINNAME=$entry
      done
      ;;
    "rancher-instance-name")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        RANCHER_NAME=$entry
      done
      ;;

    "rancher-instance-private-ip")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        RANCHER_PRIVATE_IP=$entry
      done
      ;;

    "rancher-instance-public-ip")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        RANCHER_PUBLIC_IP=$entry
      done
      ;;

    "rancher-rke-instance-name")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        RANCHER_RKE_NAME=$entry
      done
      ;;

    "suseai-instance-name")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        SUSEAI_NAME=$entry
      done
      ;;

    "suseai-instance-private-ip")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        SUSEAI_PRIVATE_IP=$entry
      done
      ;;

    "suseai-instance-public-ip")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        SUSEAI_PUBLIC_IP=$entry
      done
      ;;

    "suseai-rke-instance-name")
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        SUSEAI_RKE_NAME=$entry
      done
      ;;
  esac
done

echo ${RANCHER_PUBLIC_IP} ${RANCHER_PRIVATE_IP}   ${RANCHER_NAME} ${RANCHER_RKE_NAME}
echo ${SUSEAI_PUBLIC_IP} ${SUSEAI_PRIVATE_IP}   ${SUSEAI_NAME} ${SUSEAI_RKE_NAME}
echo 

# Tidy up
/bin/rm $TMP_FILE

