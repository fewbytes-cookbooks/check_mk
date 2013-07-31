extend ::Check_MK::Discovery

include_recipe "ark"
include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_python"

include_recipe "check_mk::backend_nagios"

cmk_package = node['check_mk']['server']['package']

ark "check_mk" do
  url cmk_package['url']
  checksum cmk_package['checksum']
  notifies :restart, "service[apache2]"
  action :put
  path ::File.dirname(node['check_mk']['build_path'])
  creates "setup.sh"
end

execute "check_mk install" do 
  command "bash setup.sh --yes"
  cwd node["check_mk"]["build_path"]
  creates "/usr/share/check_mk/modules/check_mk.py"
  environment node['check_mk']['server']['paths']
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
  group node['check_mk']['server']['group']
  mode "0755"
  action :create
  recursive true
  # TODO: Restart the backend, not nagios3
  notifies :restart, "service[nagios3]"
end

# Enable www-data to control check_mk
sudo "www-data-check_mk-automation" do
  user node['apache']['user']
  runas 'root'
  commands ['/usr/bin/check_mk --automation *']
  nopasswd true
end

# TODO: Find a better way to configure users
sysadmins = if Chef::Config[:solo]
              Chef::Log.warn("Would search for sysadmins in users data bag. Chef Solo does not support search, skipping")
              []
            else
              search_data_bag(:users, 'groups:sysadmin OR (groups:check_mk AND groups:automation)')
            end

directory ::File.dirname(node['check_mk']['server']['paths']['htpasswd_file']) do
  action :create
  owner node['check_mk']['server']['user']
  group node['check_mk']['server']['group']
  mode "0775"
  recursive true
end

file node['check_mk']['server']['paths']['htpasswd_file'] do
  action :create
  backup 5
  owner node['check_mk']['server']['user']
  group node['check_mk']['server']['group']
  mode "0664"
  content sysadmins.map{|u| "#{u['id']}:#{u['htpasswd']}"}.join("\n")
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
