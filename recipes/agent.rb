include_recipe "xinetd"

package "check-mk-agent" do
  action :install
end

check_mk_servers = if Chef::Config[:solo]
                    Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
                  else
                    search(:node, 'cluster_services:check-mk-server').map { |n| n.ip_for_node(node) }
                  end

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

Check_MK::Discovery.register_agent
node.save
