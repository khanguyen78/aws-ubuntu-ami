# SSM paths
ssm_paths = ['/svcs']

# defaults
defaults = []

templates = [
  {
    "Path":    "/templates/ldap.conf.tpl",
    "Dest":    "/etc/ldap.conf",
    "Command": "/bin/chown root:root /etc/ldap.conf && /bin/chmod 0444 /etc/ldap.conf"
  },
  {
    "Path":    "/templates/ldap.secret.tpl",
    "Dest":    "/etc/ldap.secret",
    "Command": "/bin/chown root:root /etc/ldap.secret && /bin/chmod 0600 /etc/ldap.secret"
  }
]
