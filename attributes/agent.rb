default['check_mk']['agent']['plugins'] = '/usr/lib/check_mk_agent/plugins'
default['check_mk']['agent']['local'] = '/usr/lib/check_mk_agent/local'
default['check_mk']['agent']['conf_dir'] = '/etc/check_mk'
default['check_mk']['agent']['mrpe'] = '/etc/check_mk/mrpe.cfg'
default['check_mk']['agent']['port'] = 6556

default['check_mk']['agent']['dir']['lib'] = '/usr/lib/check_mk_agent'
default['check_mk']['agent']['dir']['conf'] = '/etc/check_mk'

case platform
  when "debian", "ubuntu"
    default["check_mk"]["agent"]["package"]["url"] = "http://mathias-kettner.de/download/check-mk-agent_1.2.4p3-2_all.deb"
    default["check_mk"]["agent"]["package"]["checksum"] = "a51d855a1165dd2924fb4042ef071cfe27a6f7b11818e240bab51a3125ef92ec"
  when "centos", "redhat", "amazon", "scientific"
    default["check_mk"]["agent"]["package"]["url"] = "http://mathias-kettner.de/download/check_mk-agent-1.2.4p3-1.noarch.rpm"
    default["check_mk"]["agent"]["package"]["checksum"] = "8d9d591e03c8bcce63564ee59fb2317977a473a589e61f803d6b58c4d067cea9"
end
