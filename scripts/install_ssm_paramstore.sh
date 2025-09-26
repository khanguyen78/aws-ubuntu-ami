#!/bin/bash -e

INFO="[ INFO ] --"

echo -e "\n${INFO}\tCopying LDAP SSM paramstore files to /ssm-paramstore"
sudo mkdir -pv /ssm-paramstore/templates
sudo cp -v /tmp/ssm_paramstore.py /ssm-paramstore/ssm_paramstore.py
sudo cp -v /tmp/config.py /ssm-paramstore/config.py
sudo cp -v /tmp/templates/* /ssm-paramstore/templates/

echo -e "\n${INFO}\tSetting ownership for /ssm-paramstore"
sudo chown -Rv root:root /ssm-paramstore/

echo -e "\n${INFO}\tCopying SSM paramstore executable shell script"
sudo cp -v /tmp/init-ssm-paramstore.sh /usr/local/bin/init-ssm-paramstore.sh
sudo chmod -v +x /usr/local/bin/init-ssm-paramstore.sh
sudo chown -Rv root:root /usr/local/bin/init-ssm-paramstore.sh


echo -e "\n${INFO}\tCopying LDAP Paramstore Systemd service file"
sudo cp -v /tmp/ssm-paramstore.service /etc/systemd/system/ssm-paramstore.service
sudo chown -Rv root:root /etc/systemd/system/ssm-paramstore.service

echo -e "\n${INFO}\tDAEMON RELOAD TO POPULATE LDAP SYSTEMD SERVICE"
sudo systemctl daemon-reload

echo -e "\n${INFO}\tRESTART LDAP PARAMETER STORE SERVICE"
# sudo systemctl status ssm-paramstore
# sudo systemctl start ssm-paramstore

# sudo systemctl status --no-pager -l ssm-paramstore
