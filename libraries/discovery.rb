module Check_MK
  module Discovery
    module_function

    def register_agent(node)
      register node, 'agent'
    end

    def register_server(node)
      register node, 'server'
    end

    def agents(node)
      if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
        []
      else
        search(:node, "check_mk_discovery_provides:agent AND (#{environments(node)})")
      end
    end

    def servers(node)
      if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
        []
      else
        search(:node, "check_mk_discovery_provides:server AND (#{environments(node)})")
      end
    end

    def environments(node)
      (node['check_mk']['scope'] || [node.chef_environment]).map do e
        "chef_environment:#{e}"
      end.join('OR')
    end

    def register(node, service)
      node.override['check_mk']['discovery']['provides'] ||= []
      unless node['check_mk']['discovery']['provides'].includes?(service)
        node.override['check_mk']['discovery']['provides'] += 'agent'
      end
    end

    def cloud_location(node)
      case node["cloud"]["provider"]
        when "ec2"  #compare regions
          node["ec2"]["placement_availability_zone"][/([a-z]{2}-[a-z]+-[0-9])[a-z]/,1]
        #when adding new multi-region cloud providers - add cases here
        when nil
          false
        else
          node["cloud"]["provider"] #various single-region providers
      end rescue false # in case n["cloud"] is nil
    end

    def relative_hostname(dst, src)
      if not cloud_location(dst)
        dst["hostname"]
      elsif cloud_location(dst) == cloud_location(src)
        dst["cloud"]["local_hostname"]
      else
        dst["cloud"]["public_hostname"]
      end
    end

    def relative_ipv4(dst, src)
      if not cloud_location(dst)
        dst["ipaddress"]
      elsif cloud_location(dst) == cloud_location(src)
        dst["cloud"]["local_ipv4"]
      else
        dst["cloud"]["public_ipv4"]
      end
    end
  end
end