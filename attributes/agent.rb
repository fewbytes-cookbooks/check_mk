default['check_mk']['agent']['plugins'] = '/usr/lib/check_mk_agent/plugins'
default['check_mk']['agent']['local'] = '/usr/lib/check_mk_agent/local'
default['check_mk']['agent']['conf_dir'] = '/etc/check_mk'
default['check_mk']['agent']['mrpe'] = '/etc/check_mk/mrpe.cfg'
default['check_mk']['agent']['port'] = 6556

default['check_mk']['agent']['dir']['lib'] = '/usr/lib/check_mk_agent'
default['check_mk']['agent']['dir']['conf'] = '/etc/check_mk'

case platform
  when "debian", "ubuntu"
    default["check_mk"]["agent"]["package"]["url"] = "http://mathias-kettner.de/download/check-mk-agent_1.2.2p2-2_all.deb"
    default["check_mk"]["agent"]["package"]["checksum"] = "40af3f35e541de1b55fa4122e8382e967ab56dfa438cf096377ffdd011649ef4"
  when "centos", "redhat", "amazon", "scientific"
    default["check_mk"]["agent"]["package"]["url"] = "http://mathias-kettner.de/download/check_mk-agent-1.2.2p2-1.noarch.rpm"
    default["check_mk"]["agent"]["package"]["checksum"] = "03a163625043caa4d4208bd2e54a9402faf74a8a704a8ee43524af74b34c99fe"
end
