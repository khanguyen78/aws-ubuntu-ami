#!/bin/bash

echo -e "Getting ldap.crt from AWS ssm"
aws ssm --region us-east-1 get-parameter --with-decryption --name /svcs/ldap/cert --query Parameter.Value --output text > /home/ubuntu/ldap.crt

echo -e "\n${INFO}\tAdding LDAP Cert\n"
mv -v /home/ubuntu/ldap.crt /usr/local/share/ca-certificates/
/usr/sbin/update-ca-certificates
