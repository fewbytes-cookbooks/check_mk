# TODO: Move this to a nagios-minimal cookbook
# Minimalist nagios installation recipe
package "nagios3" do
  action :install
end

# Add the apache user to nagios group
group node['check_mk']['server']['group'] do
  action :create
  members [ node['apache']['user'] ]
  append true
  notifies :restart, "service[apache2]"
end

user node['check_mk']['server']['user'] do
  home node['check_mk']['nagios']['lib_dir']
  shell "/bin/false"
  system true
  gid "nagios"
end

# Clear nagios package config files
%w{ hostgroups_nagios2.cfg localhost_nagios2.cfg services_nagios2.cfg extinfo_nagios2.cfg }.each do |conf|
  file ::File.join(node['check_mk']['server']['paths']['nagios_conf_dir'], conf) do
    action :delete
    notifies :restart, "service[nagios3]"
  end
end

directory ::File.dirname(node['check_mk']['server']['paths']['nagios_command_pipe_path']) do
  action :create
  owner node['check_mk']['server']['user']
  group node['check_mk']['server']['group']
  mode "0755"
  recursive true
end

template node['check_mk']['server']['paths']['nagios_config_file'] do
  owner "root"
  group "root"
  mode "0644"
  variables(
    :command_file => node['check_mk']['server']['paths']['nagios_command_pipe_path'],
    :unix_socket => node['check_mk']['server']['paths']['livestatus_unix_socket']
  )
  notifies :restart, "service[nagios3]"
end

file ::File.join(node["check_mk"]["server"]["paths"]["nagios_plugins_dir"], "check_icmp") do
  owner "root"
  group "root"
  mode "4755" # Executable, Suid
end

template node['check_mk']['server']['paths']['nagios_cgi_config'] do
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file ::File.join(node['check_mk']['server']['paths']['nagios_conf_dir'], 'chef-check-mk-templates.cfg') do
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[nagios3]"
end

package node['check_mk']['nagios']['extra_plugins_package'] do
  action :install
  notifies :restart, "service[nagios3]"
  only_if { node['check_mk']['nagios']['extra_plugins'] }
end

service "nagios3" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  ignore_failure true
end

