default['check_mk']['agent']['plugins'] = '/usr/lib/check_mk_agent/plugins'
default['check_mk']['agent']['local'] = '/usr/lib/check_mk_agent/local'
default['check_mk']['agent']['conf_dir'] = '/etc/check_mk'
default['check_mk']['agent']['mrpe'] = '/etc/check_mk/mrpe.cfg'

case platform
  when "debian", "ubuntu"
    default["check_mk"]["agent"]["package"]["url"] = "http://mathias-kettner.de/download/check-mk-agent_1.2.2p1-2_all.deb"
    default["check_mk"]["agent"]["package"]["checksum"] = "91f839624e6e75154655c8276e04cc9521256f43e0f2ac8528f588ddddbe9899"
  when "centos", "redhat", "amazon", "scientific"
    default["check_mk"]["agent"]["package"]["url"] = "http://mathias-kettner.de/download/check_mk-agent-1.2.2p1-1.noarch.rpm"
    default["check_mk"]["agent"]["package"]["checksum"] = "ee257b31841c1f33a5d14f2eb01128a6b1275c880b5f333e0e0130717353f7a6"
end
