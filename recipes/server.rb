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

# TODO: Make check_mk installation process idempotent, use `source` cookbook from fewbytes-common
cmk_package = node['check_mk']['server']['package']
cmk_package_file = ::File.join("/opt", cmk_package['filename'])
cmk_package_dir = ::File.join("/opt", "#{cmk_package['name']}-#{cmk_package['version']}")

remote_file cmk_package_file do
  action :create
  source cmk_package['url']
  checksum cmk_package['checksum']
end

execute "extract-check_mk" do
  action :nothing
  command "tar -xzf #{cmk_package_file}"
  creates cmk_package_dir
  cwd "/opt"
  timeout 3600
  returns 0
  umask "022"
  subscribes :run, "remote_file[#{cmk_package_file}]"
end

execute "install-check_mk" do
  action :nothing
  command "bash setup.sh --yes"
  creates node['check_mk']['server']['conf']['dir']
  cwd cmk_package_dir
  timeout 3600
  returns 0
  umask "022"
  subscribes :run, "execute[extract-check_mk]"
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

sysadmins = search(:users, 'groups:sysadmin')

file node['check_mk']['www']['auth'] do
  action :create
  backup 5
  owner node['check_mk']['server']['user']
  group node['check_mk']['server']['group']
  mode "0664"
  content sysadmins.map{|user| "#{user['id']}:#{user['htpasswd']}"}.join("\n")
  # TODO: Restart the backend, not nagios3
  notifies :reload, "service[nagios3]"
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

template node['check_mk']['server']['conf']['main'] do
  source "main.mk.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :nodes => agents
  )
  notifies :run, "execute[inventorize-check_mk]"
end
