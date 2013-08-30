extend ::Check_MK::Discovery

include_recipe "ark"
include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_python"

include_recipe "check_mk::nagios"

cmk_package = node['check_mk']['server']['package']

ark "check_mk" do
  url cmk_package['url']
  checksum cmk_package['checksum']
  notifies :restart, "service[apache2]"
  creates "setup.sh"
end

# TODO: Find a better way to configure users
sysadmins = if Chef::Config[:solo]
              Chef::Log.warn("Would search for sysadmins in users data bag. Chef Solo does not support search, skipping")
              []
            else
              search(:users, 'groups:sysadmin OR (groups:check_mk AND groups:automation)')
            end

file node['check_mk']['server']['paths']['htpasswd_file'] do
  action :create
  backup 5
  owner node['check_mk']['server']['user']
  group node['check_mk']['server']['group']
  mode "0664"
  content sysadmins.map{|u| "#{u['id']}:#{u['htpasswd']}"}.join("\n")
end

execute "check_mk make install" do 
  command "bash setup.sh --yes"
  cwd "#{node['ark']['prefix_root']}/check_mk"
  creates "/usr/share/check_mk/modules/check_mk.py"
  environment ({'bindir' => node['check_mk']['server']['dir']['bin'],
    'confdir' => node['check_mk']['server']['dir']['conf'],
    'sharedir' => node['check_mk']['server']['dir']['share'],
    'docdir' => node['check_mk']['server']['dir']['doc'],
    'checkmandir' => node['check_mk']['server']['dir']['checkman'],
    'vardir' => node['check_mk']['server']['dir']['var'],
    'agentslibdir' => node['check_mk']['agent']['dir']['lib'],
    'agentsconfdir' => node['check_mk']['agent']['dir']['conf'],
    'nagiosuser' => node['check_mk']['nagios']['user'],
    'wwwuser' => node['apache']['user'],
    'wwwgroup' => node['apache']['group'],
    'nagios_binary' => node['check_mk']['nagios']['path']['nagios'],
    'nagios_config_file' => node['check_mk']['nagios']['path']['nagios.cfg'],
    'nagconfdir' => node['check_mk']['nagios']['dir']['conf.d'],
    'nagios_startscript' => ::File.join(node['check_mk']['nagios']['dir']['init.d'], 'nagios'),
    'nagpipe' => node['check_mk']['nagios']['path']['nagios.cmd'],
    'check_result_path' => node['check_mk']['nagios']['path']['checkresults'],
    'nagios_status_file' => node['check_mk']['nagios']['path']['status.dat'],
    'check_icmp_path' => ::File.join(node['check_mk']['nagios']['plugins']['dir']['bin'], 'check_icmp'),
    'url_prefix' => '/',
    'apache_config_dir' => node['apache']['dir'],
    'htpasswd_file' => node['check_mk']['nagios']['path']['htpasswd'],
    'nagios_auth_name' => 'Nagios Access',
    'pnptemplates' => node['check_mk']['server']['dir']['pnp-templates'],
    'rrd_path' => node['check_mk']['nagios']['dir']['rrd'],
    'rrdcached_socket' => '/tmp/rrdcached.sock',
    'enable_livestatus' => 'yes',
    'libdir' => node['check_mk']['server']['dir']['lib'],
    'livesock' => node["check_mk"]["server"]["paths"]["livestatus_unix_socket"],
    'livebackendsdir' => ::File.join(node['check_mk']['server']['dir']['share'], 'livestatus'),
    'enable_mkeventd' => 'no'
  })
end

register_server

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses node.save. Chef Solo does not support node.save, skipping")
else
  node.save
end

include_recipe "check_mk::agent"

execute "restart-check_mk" do
  action :nothing
  command "check_mk -R"
  timeout 3600
  returns 0
  ignore_failure true
end

execute "inventorize-check_mk" do
  action :nothing
  command "check_mk -II"
  timeout 3600
  returns 0
  notifies :run, "execute[restart-check_mk]"
end

directory ::File.dirname(node['check_mk']['server']['paths']['livestatus_unix_socket']) do
  owner node['check_mk']['server']['user']
  group node['apache']['group']
  mode "2755"
  action :create
  recursive true
  notifies :restart, "service[nagios]"
end

# Enable www-data to control check_mk
sudo "www-data-check_mk-automation" do
  user node['apache']['user']
  runas 'root'
  commands ['/usr/bin/check_mk --automation *']
  nopasswd true
end

template node['check_mk']['server']['paths']['apache_config_file'] do
  owner "root"
  group "root"
  mode "0644"
  variables(
    :authfile => node['check_mk']['server']['paths']['htpasswd_file']
  )
  notifies :reload, "service[apache2]"
end

# Select all the current check_mk agents
# Scope the selection, optionaly, from environments
# Filter the returned hosts and reject those marked "ignored" (node['check_mk']['ignored'] = true)
# Sort by fqdn
agents_nodes = agents.reject{|n| n['check_mk'] and n['check_mk']['ignored'] }.sort_by {|n| n['fqdn']}

pseudo_agents = []

pseudo_agents_search =
  if Chef::Config[:solo]
    Chef::Log.warn("Would search pseudo agents in check_mk data bag. Chef Solo does not support search, skipping")
    []
  else
    search_data_bag(:check_mk, "usage:pseudo_agents AND chef_environment:#{node.chef_environment}")
  end

if pseudo_agents_search.any?
  pseudo_agents_search.select{ |n| n['agents'] }.each do |item|
    pseudo_agents += item['agents'].map do |_, n|
      n['roles'] += ['pseudo-agent'] rescue n['roles'] = ['pseudo-agent']
      n['roles'] += ['ping'] unless n['roles'].include?("ping")

      n['check_mk'] ||= {}
      n['check_mk']['config'] ||= {}
      n['check_mk']['config']['extra_host_conf'] ||= {}
      n['check_mk']['config']['extra_host_conf']['check_command'] ||= 'chef-check-mk-custom!echo Default host check_command which is always true for pseudo-agents'

      n#othing
    end
  end.sort_by{|n| n['fqdn'] }
end

external_agents = []

external_agents_search =
  if Chef::Config[:solo]
    Chef::Log.warn("Would search for external agents in the check_mk data bag. Chef Solo does not support search, skipping")
    []
  else
    search_data_bag(:check_mk, "usage:external_agents AND chef_environment:#{node.chef_environment}")
  end

if external_agents_search.any?
  external_agents_search.select{ |n| n['agents'] }.each do |item|
    external_agents += item['agents'].map do |_, n|
      n['roles'] += ['external-agent'] rescue n['roles'] = ['external-agent']
      n#othing
    end
  end.sort_by{|n| n['fqdn'] }
end

checkmk_servers = servers
template node['check_mk']['server']['paths']['multisite_config_file'] do
  source "multisite.mk.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :admin_users => sysadmins.map { |user| user['id'] },
    :sites => checkmk_servers
  )
end

check_mk_nodes = agents + pseudo_agents + external_agents
template node['check_mk']['server']['paths']['main_config_file'] do
  source "main.mk.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :nodes => check_mk_nodes,
    :server => node
  )
  notifies :run, "execute[inventorize-check_mk]"
end

check_mk_user_macro "1" do
  value node["check_mk"]["server"]["paths"]["nagios_plugins_dir"]
end

check_mk_user_macro "2" do
  value node["check_mk"]["server"]["paths"]["nagios_event_handlers_dir"]
end

service "nagios" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
