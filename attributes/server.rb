default["check_mk"]["server"]["package"]["name"] = "check_mk"
default["check_mk"]["server"]["package"]["version"] = "1.2.0p3"
default["check_mk"]["server"]["package"]["filename"] = "check_mk-1.2.0p3.tar.gz"
default["check_mk"]["server"]["package"]["url"] = "http://mathias-kettner.de/download/check_mk-1.2.0p3.tar.gz"
default["check_mk"]["server"]["package"]["checksum"] = "8e626886ccc9230702adf6c3485951c211cb4c1894b12790796c4257b6816e0d"

default["check_mk"]["server"]["user"] = "nagios"
default["check_mk"]["server"]["group"] = "nagios"

default["check_mk"]["server"]["conf"]["dir"] = "/etc/check_mk"
default["check_mk"]["server"]["conf"]["main"] = "/etc/check_mk/main.mk"
default["check_mk"]["server"]["conf"]["multisite"] = "/etc/check_mk/multisite.mk"
default["check_mk"]["server"]["conf"]["unix_socket"] = "/var/log/nagios/rw/live"

default["check_mk"]["nagios"]["conf.d"] = "/etc/nagios3/conf.d"
default["check_mk"]["nagios"]["conf"] = "/etc/nagios3/nagios.cfg"
default["check_mk"]["nagios"]["cgi"] = "/etc/nagios3/cgi.cfg"
default["check_mk"]["nagios"]["command_file"] = "/var/log/nagios/rw/nagios.cmd"
default["check_mk"]["nagios"]["plugins_dir"] = "/usr/lib/nagios/plugins"

default["check_mk"]["nagios"]["extra_plugins"] = true
default["check_mk"]["nagios"]["extra_plugins_package"] = "nagios-plugins-extra"

default["check_mk"]["www"]["auth"] = "/etc/nagios3/htpasswd.users"
default["check_mk"]["www"]["user"] = "www-data"
default["check_mk"]["www"]["group"] = "www-data"
default["check_mk"]["www"]["conf"] = "/etc/apache2/conf.d/zzz_check_mk.conf"