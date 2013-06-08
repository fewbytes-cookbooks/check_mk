require 'uri'

include_recipe "xinetd"

cmk_package_uri = URI.parse(node['check_mk']['agent']['package']['url'])
cmk_package = File.join("/tmp", File.basename(cmk_package_uri.path))

remote_file cmk_package do
  action :create
  backup 5
  owner "root"
  group "root"
  mode "0644"
  source cmk_package_uri.to_s
  checksum node['check_mk']['agent']['package']['checksum']
end

package "check-mk-agent" do
  source cmk_package
  provider case File.extname(cmk_package)
            when ".deb"
              Chef::Provider::Package::Dpkg
            when ".rpm"
              Chef::Provider::Package::Rpm
            else
              Chef::Provider::Package
            end
    
end

check_mk_servers = Check_MK::Discovery.servers(node)

template "/etc/xinetd.d/check_mk" do
  source "check_mk.xinetd.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :only_from => check_mk_servers
  )
  notifies :restart, "service[xinetd]"
end

directory node['check_mk']['agent']['conf_dir'] do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

Check_MK::Discovery.register_agent(node)
if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support save.")
else
  node.save
end
