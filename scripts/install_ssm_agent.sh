#!/bin/bash

echo "Installing ssm agent"
##########################################
# SSM Agent (should already be installed)
##########################################
# Reinstall to ensure the latest version
sudo snap remove amazon-ssm-agent || true
sudo snap install amazon-ssm-agent --classic
sudo systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent
sudo systemctl status snap.amazon-ssm-agent.amazon-ssm-agent
