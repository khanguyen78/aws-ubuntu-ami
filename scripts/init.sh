#!/bin/bash -e

export DEBIAN_FRONTEND="noninteractive"
INFO="[ INFO ] --"


echo -e "\n${INFO}\tEXECUTING UBUNTU UPDATES 1\n"


SERVICES="apt-daily.service apt-daily-upgrade.service unattended-upgrades.service"

echo -e "\n${INFO}\tStopping services temporarily:\t${SERVICES}\n"
sudo systemctl stop ${SERVICES}

echo -e "\n${INFO}\tDisabling services temporarily:\t${SERVICES}\n"
sudo systemctl disable ${SERVICES}


for SERVICE_NAME in ${SERVICES};
do
  if [[ $(systemctl is-active ${SERVICE_NAME}) = "active" ]];
  then
    echo -e "\n${INFO}\tService is active, Killing service:\t${SERVICE_NAME}\n"
    sudo systemctl kill --kill-who=all ${SERVICE_NAME}
  else
    echo -e "\n${INFO}\tService is already inactive:\t${SERVICE_NAME}\n"
  fi
done

# wait until `apt-get updated` has been killed
while ! (sudo systemctl list-units --all ${SERVICES} | egrep -q '(inactive|dead|failed)')
do
  sleep 1;
done

echo -e "\n${INFO}\tPerforming systemd reload\n"
sudo systemctl daemon-reload

# Ensure process is in fact off:
echo -e "\n${INFO}\tEnsuring unattended-upgrades are in fact disabled"
while sudo systemctl is-active --quiet unattended-upgrades.service; do sleep 1; done

echo -e "\n${INFO}\tPerforming repository cache update #1.\n"
sudo apt-get update &> /dev/null

echo -e "\n${INFO}\tUpgrading packages.\n"
sudo apt-get dist-upgrade -y &> /dev/null

echo -e "\n${INFO}\tInstalling python3-pip, wget, curl, unzip and nvme-cli.\n"
sudo apt-get install -y python3-pip  wget curl unzip nvme-cli &> /dev/null

echo -e "\n${INFO}\tAdding LDAP Cert\n"
sudo /usr/sbin/update-ca-certificates

# Some module usage breaks upon ansible 4.2.0 - need to update cis role code
echo -e "\n${INFO}\tInstalling Ansible via pip3.\n"
sudo -H pip3 install ansible &> /dev/null

echo -e "\n${INFO}\tInstalling boto3 via pip3.\n"
sudo -H pip3 install boto3 &> /dev/null

echo -e "\n${INFO}\tRe-enabling services:\t${SERVICES}\n"
sudo systemctl enable ${SERVICES}
