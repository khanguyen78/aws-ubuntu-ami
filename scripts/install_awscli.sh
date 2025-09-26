#!/bin/bash

sudo apt-get update &> /dev/null
sudo apt-get install -y curl unzip software-properties-common &> /dev/null

echo -e "\n${INFO}\tInstalling awscliv2.\n"
echo "corrent working directory"
pwd

wget -O awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip &> /dev/null
unzip awscliv2.zip &> /dev/null
echo "installing aws cli"
sudo ./aws/install

echo "Set AWS Region from environment variable"
aws configure set region us-east-1
