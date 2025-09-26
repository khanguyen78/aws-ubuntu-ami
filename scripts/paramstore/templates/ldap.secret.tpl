{{ tplvars['svcs']['ldap']['rootbindpw'] | trim | env_override("rootbindpw") | default('none') }}
