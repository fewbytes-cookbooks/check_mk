default["check_mk"]["server"]["package"]["name"] = "check_mk"
default["check_mk"]["server"]["package"]["version"] = "1.2.2p2"
default["check_mk"]["server"]["package"]["filename"] = "check_mk-1.2.2p2.tar.gz"
default["check_mk"]["server"]["package"]["url"] = "http://mathias-kettner.de/download/check_mk-1.2.2p2.tar.gz"
default["check_mk"]["server"]["package"]["checksum"] = "3ef638c0de39b015e02e7d60c0d612c0fcf516a7e4766ab836dc205d7330b15f"

default["check_mk"]["server"]["user"] = "nagios"
default["check_mk"]["server"]["group"] = "nagios"

default['check_mk']['server']['dir']['bin'] = '/usr/sbin'
default['check_mk']['server']['dir']['conf'] = '/etc/check_mk'
default['check_mk']['server']['dir']['share'] = '/usr/share/check_mk'
default['check_mk']['server']['dir']['doc'] = '/usr/share/doc/check_mk'
default['check_mk']['server']['dir']['checkman'] = '/usr/share/doc/check_mk/checks'
default['check_mk']['server']['dir']['var'] = '/var/lib/check_mk'
default['check_mk']['server']['dir']['lib'] = '/usr/lib/check_mk'
default['check_mk']['server']['dir']['livebackends'] = '/usr/share/check_mk/livestatus'
default['check_mk']['server']['dir']['pnp-templates'] = '/usr/share/check_mk/pnp-templates'

default["check_mk"]["server"]["paths"]["modules_dir"] = "/usr/share/check_mk/modules"
default["check_mk"]["server"]["paths"]["checks_dir"] = "/usr/share/check_mk/checks"
default["check_mk"]["server"]["paths"]["agents_dir"] = "/usr/share/check_mk/agents"
default["check_mk"]["server"]["paths"]["doc_dir"] = "/usr/share/doc/check_mk"
default["check_mk"]["server"]["paths"]["web_dir"] = "/usr/share/check_mk/web"
default["check_mk"]["server"]["paths"]["check_manpages_dir"] = "/usr/share/doc/check_mk/checks"
default["check_mk"]["server"]["paths"]["lib_dir"] = "/usr/lib/check_mk"
default["check_mk"]["server"]["paths"]["pnp_templates_dir"] = "/usr/share/check_mk/pnp-templates"
case node.platform_family
when "debian"
  default["check_mk"]["server"]["paths"]["nagios_startscript"] = "/etc/init.d/nagios3"
  default["check_mk"]["server"]["paths"]["nagios_binary"] = "/usr/sbin/nagios3"
  default["check_mk"]["server"]["paths"]["nagios_config_file"] = "/etc/nagios3/nagios.cfg"
  default["check_mk"]["server"]["paths"]["nagios_conf_dir"] = "/etc/nagios3/conf.d"
  default["check_mk"]["server"]["paths"]["nagios_cgi_config"] = "/etc/nagios3/cgi.cfg"
  default["check_mk"]["server"]["paths"]["nagios_resource_file"] = "/etc/nagios3/resource.cfg"
  default["check_mk"]["server"]["paths"]["nagios_plugins_dir"] = "/usr/lib/nagios/plugins"
  default["check_mk"]["server"]["paths"]["nagios_event_handlers_dir"] = "/usr/lib/nagios/plugins/eventhandlers"
when "rhel", "fedora"
  default["check_mk"]["server"]["paths"]["nagios_startscript"] = "/etc/init.d/nagios"
  default["check_mk"]["server"]["paths"]["nagios_binary"] = "/usr/sbin/nagios"
  default["check_mk"]["server"]["paths"]["nagios_config_file"] = "/etc/nagios/nagios.cfg"
  default["check_mk"]["server"]["paths"]["nagios_conf_dir"] = "/etc/nagios/conf.d"
  default["check_mk"]["server"]["paths"]["nagios_cgi_config"] = "/etc/nagios/cgi.cfg"
  default["check_mk"]["server"]["paths"]["nagios_resource_file"] = "/etc/nagios/resource.cfg"
  if node['kernel']['machine'] == 'i686'
    default["check_mk"]["server"]["paths"]["nagios_plugins_dir"] = "/usr/lib/nagios/plugins"
    default["check_mk"]["server"]["paths"]["nagios_event_handlers_dir"] = "/usr/lib/nagios/plugins/eventhandlers"
  else
    default["check_mk"]["server"]["paths"]["nagios_plugins_dir"] = "/usr/lib64/nagios/plugins"
    default["check_mk"]["server"]["paths"]["nagios_event_handlers_dir"] = "/usr/lib64/nagios/plugins/eventhandlers"
  end
else
  default["check_mk"]["server"]["paths"]["nagios_startscript"] = "/etc/init.d/nagios"
  default["check_mk"]["server"]["paths"]["nagios_binary"] = "/usr/sbin/nagios"
  default["check_mk"]["server"]["paths"]["nagios_config_file"] = "/etc/nagios/nagios.cfg"
  default["check_mk"]["server"]["paths"]["nagios_conf_dir"] = "/etc/nagios/conf.d"
  default["check_mk"]["server"]["paths"]["nagios_cgi_config"] = "/etc/nagios/cgi.cfg"
  default["check_mk"]["server"]["paths"]["nagios_resource_file"] = "/etc/nagios/resource.cfg"
  default["check_mk"]["server"]["paths"]["nagios_plugins_dir"] = "/usr/lib/nagios/plugins"
  default["check_mk"]["server"]["paths"]["nagios_event_handlers_dir"] = "/usr/lib/nagios/plugins/eventhandlers"
end

default["check_mk"]["server"]["paths"]["default_config_dir"] = "/etc/check_mk"
default["check_mk"]["server"]["paths"]["check_mk_configdir"] = "/etc/check_mk/conf.d"
default["check_mk"]["server"]["paths"]["apache_config_dir"] = "/etc/apache2/conf.d"
default["check_mk"]["server"]["paths"]["apache_config_file"] = "/etc/apache2/conf.d/zzz_check_mk.conf"
default["check_mk"]["server"]["paths"]["htpasswd_file"] = "/etc/nagios/htpasswd.users"

default["check_mk"]["server"]["paths"]["var_dir"] = "/var/lib/check_mk"
default["check_mk"]["server"]["paths"]["autochecksdir"] = "/var/lib/check_mk/autochecks"
default["check_mk"]["server"]["paths"]["precompiled_hostchecks_dir"] = "/var/lib/check_mk/precompiled"
default["check_mk"]["server"]["paths"]["snmpwalks_dir"] = "/var/lib/check_mk/snmpwalks"
default["check_mk"]["server"]["paths"]["counters_directory"] = "/var/lib/check_mk/counters"
default["check_mk"]["server"]["paths"]["tcp_cache_dir"] = "/var/lib/check_mk/cache"
default["check_mk"]["server"]["paths"]["logwatch_dir"] = "/var/lib/check_mk/logwatch"
default["check_mk"]["server"]["paths"]["nagios_objects_file"] = "/etc/nagios3/conf.d/check_mk_objects.cfg"
default["check_mk"]["server"]["paths"]["nagios_status_file"] = "/var/cache/nagios3/status.dat"

default["check_mk"]["server"]["paths"]["nagios_command_pipe_path"] = "/var/log/nagios/rw/nagios.cmd"
default["check_mk"]["server"]["paths"]["check_result_path"] = "/var/lib/nagios3/spool/checkresults"
default["check_mk"]["server"]["paths"]["livestatus_unix_socket"] = "/var/log/nagios/rw/live"

default["check_mk"]["server"]["paths"]["main_config_file"] = ::File.join(check_mk["server"]["paths"]["default_config_dir"], "main.mk")
default["check_mk"]["server"]["paths"]["multisite_config_file"] = ::File.join(check_mk["server"]["paths"]["default_config_dir"], "multisite.mk")
default["check_mk"]["server"]["paths"]["wato_snapshot_dir"] = ::File.join(check_mk["server"]["paths"]["var_dir"], "wato", "snapshots")


default["check_mk"]["nagios"]["extra_plugins"] = true
default["check_mk"]["nagios"]["extra_plugins_package"] = "nagios-plugins-extra"

# for sudo
include_attribute "sudo::default"
default["authorization"]["sudo"]["include_sudoers_d"] = true
