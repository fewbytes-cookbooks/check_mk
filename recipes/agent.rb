include_recipe "xinetd"

package "check-mk-agent" do
  action :install
end

provide_service "check-mk-agent"

template "/etc/xinetd.d/check_mk" do
  source "check_mk.xinetd.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :only_from => all_providers_for_service('check-mk-server').map { |n| n.ip_for_node(node) }
  )
  notifies :restart, "service[xinetd]"
end

directory node['check_mk']['agent']['conf_dir'] do
  action :create
  owner "root"
  group "root"
  mode "0755"
end
