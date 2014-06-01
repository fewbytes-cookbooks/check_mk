default['check_mk']['agent']['plugins'] = '/usr/lib/check_mk_agent/plugins'
default['check_mk']['agent']['local'] = '/usr/lib/check_mk_agent/local'
default['check_mk']['agent']['conf_dir'] = '/etc/check_mk'
default['check_mk']['agent']['mrpe'] = '/etc/check_mk/mrpe.cfg'
default['check_mk']['agent']['port'] = 6556

default['check_mk']['agent']['dir']['lib'] = '/usr/lib/check_mk_agent'
default['check_mk']['agent']['dir']['conf'] = '/etc/check_mk'

case platform
  when "debian", "ubuntu"
    default["check_mk"]["agent"]["package"]["url"] = "http://inneractive-deploy.s3.amazonaws.com/check_mk/check-mk-agent_1.2.4p3-2_all.deb"
    default["check_mk"]["agent"]["package"]["checksum"] = "127fae672cd6c0ceb61a994460216e8f5e6e30d05e293319ca4f45ebd291219b"
  when "centos", "redhat", "amazon", "scientific"
    default["check_mk"]["agent"]["package"]["url"] = "http://inneractive-deploy.s3.amazonaws.com/check_mk/check_mk-agent-logwatch-1.2.4p3-1.noarch.rpm"
    default["check_mk"]["agent"]["package"]["checksum"] = "9c08666228ec84b3459af4edbe63620052ec64cddeeb407c25a0f76d6509aff6"
end
