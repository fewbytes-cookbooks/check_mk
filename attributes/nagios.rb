include_attribute "check_mk::server"
include_attribute "check_mk::pnp4nagios"
default['check_mk']['nagios']['package']['url'] = 'http://sourceforge.net/projects/nagios/files/nagios-3.x/nagios-3.5.0/nagios-3.5.0.tar.gz'
default['check_mk']['nagios']['package']['version'] = '3.5.0'
default['check_mk']['nagios']['package']['checksum'] =
    '469381b2954392689c85d3db733e8da4bd43b806b3d661d1a7fbd52dacc084db'

default['check_mk']['nagios']['user'] = 'nagios'
default['check_mk']['nagios']['group'] = 'nagios'

default['check_mk']['nagios']['dir']['prefix'] = '/usr'
default['check_mk']['nagios']['dir']['man'] = '/usr/share/man'
default['check_mk']['nagios']['dir']['bin'] = '/usr/sbin'
default['check_mk']['nagios']['dir']['sbin'] = '/usr/lib/cgi-bin/nagios'
default['check_mk']['nagios']['dir']['data'] = '/usr/share/nagios/htdocs'
default['check_mk']['nagios']['dir']['sysconf'] = '/etc/nagios'
default['check_mk']['nagios']['dir']['info'] = '/usr/share/info'
default['check_mk']['nagios']['dir']['libexec'] = '/usr/lib/nagios/libexec'
default['check_mk']['nagios']['dir']['localstate'] = '/var/lib/nagios'
default['check_mk']['nagios']['dir']['rw'] = '/var/lib/nagios/rw'
default['check_mk']['nagios']['dir']['spool'] = '/var/lib/nagios/spool'
default['check_mk']['nagios']['dir']['run'] = '/var/run/nagios'
default['check_mk']['nagios']['dir']['conf.d'] = ::File.join(node['check_mk']['nagios']['dir']['sysconf'], 'conf.d')
default['check_mk']['nagios']['dir']['init.d'] = '/etc/init.d'
default['check_mk']['nagios']['dir']['rrd'] = ::File.join(node['check_mk']['nagios']['dir']['localstate'], 'rrd')
default['check_mk']['nagios']['dir']['objects'] = ::File.join(check_mk['nagios']['dir']['sysconf'], 'objects')
# Web stuff
default['check_mk']['nagios']['www']['html'] = '/nagios'
default['check_mk']['nagios']['www']['cgi'] = '/cgi-bin/nagios'

# File paths
%W(nagios.cfg cgi.cfg resource.cfg).each do |cfg_file|
  default['check_mk']['nagios']['path'][cfg_file] = ::File.join(node['check_mk']['nagios']['dir']['sysconf'], cfg_file)
end

# Nagios cmd path
default['check_mk']['nagios']['path']['nagios.cmd'] = ::File.join(node['check_mk']['nagios']['dir']['rw'], 'nagios.cmd')

# Nagios PID file path
default['check_mk']['nagios']['path']['lockfile'] = ::File.join(node['check_mk']['nagios']['dir']['run'], 'nagios.pid')

# Nagios status file
default['check_mk']['nagios']['path']['status.dat'] = ::File.join(node['check_mk']['nagios']['dir']['localstate'], 'status.dat')

# Nagios check results path
default['check_mk']['nagios']['path']['checkresults'] = ::File.join(node['check_mk']['nagios']['dir']['spool'], 'checkresults')

# Nagios binary path
default['check_mk']['nagios']['path']['nagios'] = ::File.join(node['check_mk']['nagios']['dir']['bin'], 'nagios')
default['check_mk']['nagios']['conf']['main']['object_cache_file'] = "/var/lib/nagios/objects.cache"

# Parameters for nagios/cgi.cfg (http://nagios.sourceforge.net/docs/3_0/configcgi.html)
#cgi_cfg = {
#  main_config_file: node['check_mk']['nagios']['nagios.cfg'],
#  physical_html_path: node['check_mk']['nagios']['dir']['share'],
#  url_html_path: '/nagios',
#  use_authentication: 1,
#  default_user_name: nil,
#  authorized_for_system_information: nil,
#  authorized_for_system_commands: nil,
#  authorized_for_configuration_information: nil,
#  authorized_for_all_hosts: nil,
#  authorized_for_all_host_commands: nil,
#  authorized_for_all_services: nil,
#  authorized_for_all_service_commands: nil,
#  authorized_for_read_only: nil,
#  lock_author_names: 1,
#  statusmap_background_image: nil,
#  color_transparency_index_r: nil,
#  color_transparency_index_g: nil,
#  color_transparency_index_b: nil,
#  default_statusmap_layout: 5,
#  statuswrl_include: nil,
#  default_statuswrl_layout: 4,
#  ping_syntax: '/bin/ping -n -U -c 5 $HOSTADDRESS$',
#  refresh_rate: 90,
#  escape_html_tags: 1,
#  host_unreachable_sound: nil,
#  host_down_sound: nil,
#  service_critical_sound: nil,
#  service_warning_sound: nil,
#  service_unknown_sound: nil,
#  notes_url_target: '_blank',
#  action_url_target: '_blank',
#  enable_splunk_integration: nil,
#  splunk_url: nil
#}

#cgi_cfg.each_pair do |key, value|
#  unless value == nil
#    default['check_mk']['nagios']['conf']['cgi'][key] = value
#  end
#end
default['check_mk']['nagios']['conf']['cgi']['main_config_file'] = node['check_mk']['nagios']['path']['nagios.cfg']

# Parameters for nagios/nagios.cfg should go under main (http://nagios.sourceforge.net/docs/3_0/configmain.html)
default['check_mk']['nagios']['conf']['main']['log_file'] = ::File.join(node['check_mk']['nagios']['dir']['localstate'],
                                                                       'nagios.log')

default['check_mk']['nagios']['conf']['main']['cfg_dir'] = [check_mk['nagios']['dir']['conf.d']]
default['check_mk']['nagios']['conf']['main']['illegal_macro_output_chars'] = '`~$&|'"<>"
default['check_mk']['nagios']['conf']['main']['low_service_flap_threshold'] = 5.0
default['check_mk']['nagios']['conf']['main']['high_service_flap_threshold'] = 20.0
default['check_mk']['nagios']['conf']['main']['low_host_flap_threshold'] = 5.0
default['check_mk']['nagios']['conf']['main']['high_host_flap_threshold'] = 20.0
default['check_mk']['nagios']['conf']['main']['enable_flap_detection'] = 1
default['check_mk']['nagios']['conf']['main']['date_format'] = 'iso8601'
default['check_mk']['nagios']['conf']['main']['interval_length'] = 60
default['check_mk']['nagios']['conf']['main']['process_performance_data'] = 1
default['check_mk']['nagios']['conf']['main']['event_broker_options'] = -1
default['check_mk']['nagios']['conf']['main']['cfg_file'] = %w(
  contacts.cfg
  localhost.cfg
  templates.cfg
  timeperiods.cfg
  commands.cfg).map {|f| ::File.join(check_mk['nagios']['dir']['objects'], f)}
default['check_mk']['nagios']['conf']['main']['resource_file'] = check_mk['nagios']['path']['resource.cfg']
default['check_mk']['nagios']['conf']['main']['broker_module'] = [
    "#{::File.join(check_mk['server']['dir']['lib'], "livestatus.o")} pnp_path=#{check_mk['pnp4nagios']['perfdata_dir']} #{check_mk["server"]["paths"]["livestatus_unix_socket"]}",
    "#{check_mk['pnp4nagios']['npcd_broker_library']} config_file=#{check_mk['pnp4nagios']['npcd_config_file']}"
  ]
  #cfg_file: [],
  #object_cache_file: ::File.join(node['check_mk']['nagios']['dir']['var'], 'objects.cache'),
  #precached_object_file: ::File.join(node['check_mk']['nagios']['dir']['var'], 'objects.precache'),
  #resource_file: node['check_mk']['nagios']['path']['resource.cfg'],
  #temp_file: ::File.join(node['check_mk']['nagios']['dir']['var'], 'nagios.tmp'),
  #temp_path: '/tmp',
  #status_file: ::File.join(node['check_mk']['nagios']['dir']['var'], 'status.dat'),
  #status_update_interval: 10,
  #nagios_user: node['check_mk']['nagios']['user'],
  #nagios_group: node['check_mk']['nagios']['group'],
  #enable_notifications: 1,
  #execute_service_checks: 1,
  #accept_passive_service_checks: 1,
  #execute_host_checks: 1,
  #accept_passive_host_checks: 1,
  #enable_event_handlers: 1,
  #log_rotation_method: 'd',
  #log_archive_path: ::File.join(node['check_mk']['nagios']['dir']['var'], 'archives'),
  #check_external_commands: 1,
  #command_check_interval: -1,
  #command_file: ::File.join(node['check_mk']['nagios']['dir']['rw'], 'nagios.cmd'),
  #check_for_updates: 0,
  #bare_update_checks: 0,
  #lock_file: ::File.join(node['check_mk']['nagios']['dir']['var'], 'nagios.lock'),
  #retain_state_information: 1,
  #state_retention_file: ::File.join(node['check_mk']['nagios']['dir']['var'], 'retention.dat'),
  #retention_update_interval: 0,
  #use_retained_program_state: 1,
  #use_retained_scheduling_info: 1,
  #retained_host_attribute_mask: nil,
  #retained_service_attribute_mask: nil,
  #retained_process_host_attribute_mask: nil,
  #retained_process_service_attribute_mask: nil,
  #retained_contact_host_attribute_mask: nil,
  #retained_contact_service_attribute_mask: nil,
  #use_syslog: nil,
  #log_notifications: nil,
  #log_service_retries: nil,
  #log_host_retries: nil,
  #log_event_handlers: nil,
  #log_initial_states: 0,
  #log_external_commands: 1,
  #log_passive_checks: 1,
  #global_host_event_handler: nil,
  #global_service_event_handler: nil,

# Nagios plugins
default['check_mk']['nagios']['plugins']['url'] = 'https://www.nagios-plugins.org/download/nagios-plugins-1.4.16.tar.gz'
default['check_mk']['nagios']['plugins']['version'] = '1.4.16'
default['check_mk']['nagios']['plugins']['checksum'] = '52db48b15572b98c6fcd8aaec2ef4d2aad7640d3'
    
default['check_mk']['nagios']['plugins']['dir']['bin'] = '/usr/local/nagios/bin'
