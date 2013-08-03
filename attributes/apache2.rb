# "Steal" root
default['check_mk']['apache']['redirect_root'] = true

# Enable SSL
default['check_mk']['apache']['enable_ssl'] = true
default['check_mk']['apache']['force_ssl'] = node['check_mk']['apache']['enable_ssl']

# Virtual host for monitoring
default['check_mk']['apache']['virtualhost'] = '*'
