#!/bin/bash
set -euxo pipefail


# Update packages
echo "Running apt update and apt upgrade"
#'timeout 180 bash -c ''while sudo lsof /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock; do echo "APT is busy, waiting..."; sleep 15; done'' && sudo DEBIAN_FRONTEND=noninteractive apt-get update -y' 
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y &> /dev/null

echo "running dist upgrade"
#'timeout 180 bash -c ''while sudo lsof /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock; do echo "APT is busy, waiting..."; sleep 15; done'' && sudo DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y' 
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y &> /dev/null

# Install CIS-related tools
echo "Install CIS-related tools"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y auditd ufw aide apparmor-utils libpam-cracklib &> /dev/null

# Enable UFW firewall
echo "Enable UFW firewall"
echo "deny incoming"
sudo ufw default deny incoming
echo "allow outgoing"
sudo ufw default allow outgoing
sudo ufw enable

# Set password policy
echo "Set password policy"
echo "max days"
sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
echo "min days"
sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   10/' /etc/login.defs
echo "warn age"
sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

# Disable root login over SSH
echo "Disable root login over SSH"
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Ensure SSH uses protocol 2
echo "Ensure SSH uses protocol 2"
echo "Protocol 2" | sudo tee -a /etc/ssh/sshd_config

# Restart SSH to apply settings
echo "Restart SSH to apply settings"
sudo systemctl restart ssh

# Enable auditing
echo "Enable auditing"
sudo systemctl enable auditd
echo "start auditd"
sudo systemctl start auditd

# Run AIDE init
echo "Run AIDE init"
sudo aideinit

# Save AIDE database
echo "Save AIDE database"
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

echo "CIS hardening complete."
