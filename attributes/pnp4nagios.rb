default['check_mk']['pnp4nagios']['perfdata_dir'] = "/var/lib/pnp4nagios/perfdata"
default['check_mk']['pnp4nagios']['npcd_config_file'] = "/etc/pnp4nagios/npcd.cfg"
default['check_mk']['pnp4nagios']['npcd_spool_dir'] = "/var/spool/pnp4nagios/npcd/"
default['check_mk']['pnp4nagios']['perfdata_file'] = "/var/spool/pnp4nagios/nagios/perfdata.dump"
default['check_mk']['pnp4nagios']['log_dir'] = "/var/log/pnp4nagios"
default['check_mk']['pnp4nagios']['npcd_broker_library'] = case platform
                                                   when "ubuntu", "debian"
                                                    "/usr/lib/pnp4nagios/npcdmod.o"
                                                   when "centos", "redhat", "fedora", "ec2"
                                                     if kernel["machine"] == "x86_64"
                                                       "/usr/lib64/pnp4nagios/npcdmod.o"
                                                     else
                                                       "/usr/lib/pnp4nagios/npcdmod.o"
                                                     end
                                                   else
                                                    "/usr/lib/pnp4nagios/npcdmod.o"
                                                   end
