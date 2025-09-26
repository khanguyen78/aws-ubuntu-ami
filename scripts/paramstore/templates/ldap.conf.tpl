### DON'T MAKE CHANGES TO THIS FILE, THEY'LL JUST BE OVERWRITTEN
### LDAP CLIENT CONFIGURATION

# Base properties
base {{ tplvars['svcs']['ldap']['base'] | trim | env_override("ldap_base") | default('none') }}
uri {{ tplvars['svcs']['ldap']['uri'] | trim | env_override("ldap_uri") | default('none') }}
rootbinddn {{ tplvars['svcs']['ldap']['rootbinddn'] | trim | env_override("rootbinddn") | default('none') }}

# TLS properties
ssl start_tls
tls_reqcert allow
tls_checkpeer no
tls_cacertdir /etc/ssl/certs

# PAM properties
pam_password exop

# NSWITCH properties
nss_initgroups_ignoreusers Debian-exim,backup,bin,clamav,daemon,games,gnats,irc,libuuid,list,lp,mail,mysql,man,news,nslcd,ntp,pe-puppet,proxy,puppet,root,snmp,sshd,statd,sync,sys,syslog,uucp,www-data,ubuntu,ec2_user,pe-puppet,pe-activemq,pe-postgres,pe-webserver,peadmin,pe-puppetdb,pe-console-services,pe-orchestration-services,vagrant
