include_recipe "xinetd"

check_mk_servers = if Chef::Config[:solo]
                    Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
                  else
                    search(:node, 'cluster_services:check-mk-server').map { |n| Check_MK::Discovery.relative_ipv4(n, node) }
                  end

template "/etc/xinetd.d/livestatus" do
  source "livestatus.xinetd.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :only_from => check_mk_servers,
    :nagios_user => node['check_mk']['server']['user'],
    :unix_socket => node['check_mk']['server']['paths']['livestatus_unix_socket']
  )
  notifies :restart, "service[xinetd]"
end
