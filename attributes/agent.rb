default['check_mk']['agent']['plugins'] = '/usr/lib/check_mk_agent/plugins'
default['check_mk']['agent']['local'] = '/usr/lib/check_mk_agent/local'
default['check_mk']['agent']['conf_dir'] = '/etc/check_mk'
default['check_mk']['agent']['mrpe'] = '/etc/check_mk/mrpe.cfg'

case platform
when "debian", "ubuntu"
  default["check_mk"]["agent"]["package"]["url"] = "http://mathias-kettner.de/download/check-mk-agent_1.2.2p1-2_all.deb"
  default["check_mk"]["agent"]["package"]["checksum"] = "91f839624e6e75154655c8276e04cc9521256f43e0f2ac8528f588ddddbe9899"
end