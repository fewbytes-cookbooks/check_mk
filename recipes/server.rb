include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_python"

include_recipe "check_mk::backend_nagios"

# Add the apache user to nagios group
group node['check_mk']['server']['group'] do
  action :create
  members [ node['check_mk']['www']['user'] ]
  append true
  notifies :restart, "service[apache2]"
end

cmk_package = node['check_mk']['server']['package']

source_package "check_mk" do
  source_type "tarball"
  source cmk_package['url']
  checksum cmk_package['checksum']
  build_command "bash setup.sh --yes"
  creates "/usr/share/check_mk/modules/check_mk.py"
  notifies :restart, "service[apache2]"
end

provide_service "check-mk-server"
include_recipe "check_mk::agent"

execute "restart-check_mk" do
  action :nothing
  command "check_mk -R"
  cwd node['check_mk']['server']['conf']['dir']
  timeout 3600
  returns 0
  ignore_failure true
end

execute "inventorize-check_mk" do
  action :nothing
  command "check_mk -II"
  cwd node['check_mk']['server']['conf']['dir']
  timeout 3600
  returns 0
  notifies :run, "execute[restart-check_mk]"
end

directory ::File.dirname(node['check_mk']['www']['auth']) do
  action :create
  owner "root"
  group "root"
  mode "0755"
  recursive true
end

directory ::File.dirname(node['check_mk']['server']['conf']['unix_socket']) do
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
  user node['check_mk']['www']['user']
  runas 'root'
  commands ['/usr/bin/check_mk --automation *']
  nopasswd true
end

# TODO: Find a better way to configure users
sysadmins = search(:users, 'groups:sysadmin')

file node['check_mk']['www']['auth'] do
  action :create
  backup 5
  owner node['check_mk']['server']['user']
  group node['check_mk']['server']['group']
  mode "0664"
  content sysadmins.map{|u| "#{u['id']}:#{u['htpasswd']}"}.join("\n")
end

template node['check_mk']['www']['conf'] do
  owner "root"
  group "root"
  mode "0644"
  variables(
    :authfile => node['check_mk']['www']['auth']
  )
  notifies :reload, "service[apache2]"
end

template node['check_mk']['server']['conf']['multisite'] do
  source "multisite.mk.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :admin_users => sysadmins.map { |user| user['id'] }
  )
end

agents = all_providers_for_service('check-mk-agent')
pseudo_agents = []

pseudo_agents_search =
  begin
    search(:check_mk, "usage:pseudo_agents AND chef_environment:#{node.chef_environment}")
  rescue OpenURI::HTTPError
    []
  rescue Net::HTTPServerException
    []
  end

if pseudo_agents_search.any?
  pseudo_agents_search.select{ |n| n['agents'] }.each do |item|
    pseudo_agents += item['agents'].map do |_, n|
      n['roles'] += ['pseudo-agent'] rescue n['roles'] = ['pseudo-agent']

      n['check_mk'] ||= {}
      n['check_mk']['config'] ||= {}
      n['check_mk']['config']['extra_host_conf'] ||= {}
      n['check_mk']['config']['extra_host_conf']['check_command'] ||= 'chef-check-mk-custom!echo Default host check_command which is always true for pseudo-agents'

      n#othing
    end
  end
end

template node['check_mk']['server']['conf']['main'] do
  source "main.mk.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :nodes => agents + pseudo_agents
  )
  notifies :run, "execute[inventorize-check_mk]"
end
