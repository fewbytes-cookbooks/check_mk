include_recipe 'ark'
include_recipe 'check_mk::apache2'

include_recipe 'php'
include_recipe 'php::module_gd'

# Create the nagios group
group node['check_mk']['nagios']['group'] do
  system true
end

# Create the nagios user
user node['check_mk']['nagios']['user'] do
  gid node['check_mk']['nagios']['group']
  system true
  shell '/bin/false'
end

# Create the configuration directory
dir_etc = node['check_mk']['nagios']['dir']['sysconf']
directory dir_etc do
  owner node['check_mk']['nagios']['user']
  group node['check_mk']['nagios']['group']
  mode "0755"
  action :create
  recursive true
end

directory node['check_mk']['nagios']['dir']['conf.d'] do
  mode "0755"
end

directory node['check_mk']['nagios']['dir']['objects'] do
  mode "0755"
end

%w(localhost.cfg templates.cfg timeperiods.cfg commands.cfg contacts.cfg).each do |nagios_file|
  cookbook_file ::File.join(node['check_mk']['nagios']['dir']['objects'], nagios_file) do
    mode "0755"
  end
end

# Download and unpack
ark 'nagios' do
  url node['check_mk']['nagios']['package']['url']
  version node['check_mk']['nagios']['package']['version']
  checksum node['check_mk']['nagios']['package']['checksum']
end

# Compile and install
execute 'nagios configure' do
  command "./configure --prefix=#{node['check_mk']['nagios']['dir']['prefix']} \
    --mandir=#{node['check_mk']['nagios']['dir']['man']} \
    --bindir=#{node['check_mk']['nagios']['dir']['bin']} \
    --sbindir=#{node['check_mk']['nagios']['dir']['sbin']} \
    --datadir=#{node['check_mk']['nagios']['dir']['data']} \
    --sysconfdir=#{node['check_mk']['nagios']['dir']['sysconf']} \
    --infodir=#{node['check_mk']['nagios']['dir']['info']} \
    --libexecdir=#{node['check_mk']['nagios']['dir']['libexec']} \
    --localstatedir=#{node['check_mk']['nagios']['dir']['localstate']} \
    --enable-event-broker \
    --with-nagios-user=#{node['check_mk']['nagios']['user']} \
    --with-nagios-group=#{node['check_mk']['nagios']['group']} \
    --with-command-user=#{node['check_mk']['nagios']['user']} \
    --with-command-group=#{node['check_mk']['nagios']['group']} \
    --with-init-dir=#{node['check_mk']['nagios']['dir']['init.d']} \
    --with-lockfile=#{node['check_mk']['nagios']['path']['lockfile']} \
    --with-mail=/usr/bin/mail \
    --with-perlcache \
    --with-htmurl=#{node['check_mk']['nagios']['www']['html']} \
    --with-cgiurl=#{node['check_mk']['nagios']['www']['cgi']}"
  cwd "#{node['ark']['prefix_root']}/nagios"
  creates ::File.join(node['ark']['prefix_root'], 'nagios', 'Makefile')
end

execute 'nagios make all' do
  command 'make all'
  cwd "#{node['ark']['prefix_root']}/nagios"
  creates ::File.join(node['ark']['prefix_root'], 'nagios', 'base', 'nagios')
end

execute 'nagios make install' do
  command 'make install'
  cwd "#{node['ark']['prefix_root']}/nagios"
  not_if "#{node['check_mk']['nagios']['path']['nagios']} |
grep 'Nagios Core #{node['check_mk']['nagios']['package']['version']}'"
end

execute 'nagios make install-init' do
  command 'make install-init'
  cwd "#{node['ark']['prefix_root']}/nagios"
  not_if { ::File.exist?("/etc/init.d/nagios") }
end

directory dir_etc do
  owner node['check_mk']['nagios']['user']
  group node['check_mk']['nagios']['group']
  mode '0755'
end

template node['check_mk']['nagios']['path']['cgi.cfg'] do
  owner node['check_mk']['nagios']['user']
  group node['check_mk']['nagios']['group']
  mode '0644'
  notifies :reload, 'service[nagios]'
end

template node['check_mk']['nagios']['path']['nagios.cfg'] do
  owner node['check_mk']['nagios']['user']
  group node['check_mk']['nagios']['group']
  mode '0644'
  notifies :reload, 'service[nagios]'
end


# Nagios plugins

# Download and unpack
ark 'nagios-plugins' do
  url node['check_mk']['nagios']['plugins']['url']
  version node['check_mk']['nagios']['plugins']['version']
  checksum node['check_mk']['nagios']['plugins']['checksum']
end

# Compile and install
execute 'nagios-plugins configure' do
  command "./configure --with-nagios-user=#{node['check_mk']['nagios']['user']} \
    --with-nagios-group=#{node['check_mk']['nagios']['group']} \
    --mandir=#{node['check_mk']['nagios']['dir']['man']} \
    --bindir=#{node['check_mk']['nagios']['dir']['bin']} \
    --sbindir=#{node['check_mk']['nagios']['dir']['sbin']} \
    --datadir=#{node['check_mk']['nagios']['dir']['data']} \
    --sysconfdir=#{node['check_mk']['nagios']['dir']['sysconf']} \
    --infodir=#{node['check_mk']['nagios']['dir']['info']} \
    --libexecdir=#{node['check_mk']['nagios']['dir']['libexec']} \
    --localstatedir=#{node['check_mk']['nagios']['dir']['localstate']}"
  cwd "#{node['ark']['prefix_root']}/nagios-plugins"
  creates ::File.join(node['ark']['prefix_root'], 'nagios-plugins', 'Makefile')
end

execute 'nagios-plugins make and install' do
  command 'make && make install'
  cwd "#{node['ark']['prefix_root']}/nagios-plugins"
  creates File.join(node['check_mk']['nagios']['dir']['libexec'], "check_icmp")
end
