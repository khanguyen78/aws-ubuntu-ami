#!/bin/bash

echo -e "\n${INFO}\tInstalling awscliv2.\n"
wget -O awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip &> /dev/null
unzip awscliv2.zip &> /dev/null
sudo ./aws/install

echo "Set AWS Region from environment variable"
aws configure set region us-east-1

echo "Finished installing AWS CLI"