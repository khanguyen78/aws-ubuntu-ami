#!/bin/bash -e

export DEBIAN_FRONTEND="noninteractive"
INFO="[ INFO ] --"

echo -e "\n####################################################################"
echo -e "\n${INFO}\tBEGINNING CLEAN UP AND ANY REQUIRED FIXES"


echo -e "\n${INFO}\tDISABLING AND CLEANING UP PARAMSTORE FROM SYSTEM"
systemctl disable ssm-paramstore
rm -rv /etc/systemd/system/ssm-paramstore.service
rm -rfv /ssm-paramstore

echo -e "\n${INFO}\tPERFORMING APT AUTOREMOVE AND CLEAN"
apt-get autoremove -y && apt-get clean -y


echo -e "\n${INFO}\tPERFORMING FIX FOR 3.3.4 - Suspicious packets logging"
sysctl -w net.ipv4.conf.all.log_martians=1 && sysctl -w net.ipv4.conf.default.log_martians=1 && sysctl -w net.ipv4.route.flush=1

echo -e "\n${INFO}\tPERFORMING FIX FOR 6.1.11 and 6.1.12 - CLEANUP OF ORPHAN DIRECTORIES"
PARTITION_SOURCE_LIST=$(df -h --output=target -x tmpfs -x devtmpfs | grep -v Mounted)
ORPHANED_UNOWNED=$(find ${PARTITION_SOURCE_LIST} -xdev -nouser)
for ORPHAN_DIR in ${ORPHANED_UNOWNED};
do
  echo -e "\n${INFO}\tRemoving orphaned/unowned:\t${ORPHAN_DIR}"
  rm -rfv ${ORPHAN_DIR}
done

ORPHANED_UNGROUPED=$(find ${PARTITION_SOURCE_LIST} -xdev -nogroup)
for ORPHAN_DIR in ${ORPHANED_UNGROUPED};
do
  echo -e "\n${INFO}\tRemoving orphaned/ungrouped:\t${ORPHAN_DIR}"
  rm -rfv ${ORPHAN_DIR}
done

echo -e "\n${INFO}\tCLEANING UP ALL JOURNALCTL LOGS"
systemctl stop systemd-journald
systemctl stop systemd-journald-dev-log.socket
systemctl stop systemd-journald-audit.socket
systemctl stop systemd-journald.socket
rm -Rv /var/log/journal/*

echo -e "\n${INFO}\tCLEANING UP ALL ARCHIVED GZ TYPE LOG FILES"
find /var/log -maxdepth 4 -type f \( -name "*gz*" -o -name "*xz*"  \) -exec echo -e "\nRemoving:" {} \; -exec rm -v {} \;

echo -e "\n${INFO}\tCLEANING UP ALL LOG FILES"
find /var/log -maxdepth 4 -type f \( -name "*log*" -o -name "*amazon-ssm-agent*" -o -name "*dmesg*" -o -name "*mail*" -o -name "*messages*" -o -name "*tmp*" -o -name "*warn*" \) -exec echo -e "\nTruncating to 0 bytes:" {} \; -exec truncate -s 0 {} \;

echo -e "\n${INFO}\tREMOVING ARTIFACTS UPLOADED to /home/ubuntu"
rm -rf /home/ubuntu/*

echo -e "\n${INFO}\tUPDATING AIDE DB AND RESET TO NEW ONE"
/usr/bin/nice -n -19 /usr/bin/aide.wrapper --update &> /dev/null || true && mv -v /var/lib/aide/aide.db.new /var/lib/aide/aide.db

echo -e "\n${INFO}\tREMOVING AUTHORIZED KEYS"
rm -rf /home/ubuntu/.ssh/authorized_keys
rm -rf /root/.ssh/authorized_keys

echo -e "\n####################################################################"
