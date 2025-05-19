name: Harden Ubuntu
description: Basic system hardening
schemaVersion: 1.0
phases:
  build:
    commands:
      - apt update -y
      - apt install -y fail2ban ufw
      - ufw allow OpenSSH
      - ufw --force enable

