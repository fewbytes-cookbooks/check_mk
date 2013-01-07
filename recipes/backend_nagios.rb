# Minimalist nagios installation recipe
package "nagios3" do
  action :install
end

# Clear nagios package config files
%w{ hostgroups_nagios2.cfg localhost_nagios2.cfg services_nagios2.cfg extinfo_nagios2.cfg }.each do |conf|
  file ::File.join('/etc', 'nagios3', 'conf.d', conf) do
    action :delete
    notifies :restart, "service[nagios3]"
  end
end

directory ::File.dirname(node['check_mk']['nagios']['command_file']) do
  action :create
  owner node['check_mk']['server']['user']
  group node['check_mk']['server']['group']
  mode "0755"
  recursive true
end

template node['check_mk']['nagios']['conf'] do
  owner "root"
  group "root"
  mode "0644"
  variables(
    :command_file => @node['check_mk']['nagios']['command_file'],
    :unix_socket => @node['check_mk']['server']['conf']['unix_socket']
  )
  notifies :restart, "service[nagios3]"
end

file ::File.join(node['check_mk']['nagios']['plugins_dir'], "check_icmp") do
  owner "root"
  group "root"
  mode "4755" # Executable, Suid
end

template node['check_mk']['nagios']['cgi'] do
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file ::File.join(node['check_mk']['nagios']['conf.d'], 'chef-check-mk-templates.cfg') do
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[nagios3]"
end

if node['check_mk']['nagios']['extra_plugins']
  package node['check_mk']['nagios']['extra_plugins_package'] do
    action :install
    notifies :restart, "service[nagios3]"
  end
end

service "nagios3" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  ignore_failure true
end

