module Check_MK
  module Discovery
    def register_agent
      register 'agent'
    end

    def register_server
      register 'server'
    end

    def agents
      search(:node, "check_mk_discovery_provides:agent AND #{environments}")
    end

    def servers
      search(:node, "check_mk_discovery_provides:server AND (#{environments})")
    end

    def environments
      (node['check_mk']['scope'] || [node.chef_environment]).map do e
        "chef_environment:#{e}"
      end.join('OR')
    end

    def register(service)
      node.override['check_mk']['discovery']['provides'] ||= []
      unless node['check_mk']['discovery']['provides'].includes?(service)
        node.override['check_mk']['discovery']['provides'] += 'agent'
      end
    end

    def cloud_location(n)
      case n["cloud"]["provider"]
        when "ec2"  #compare regions
          n["ec2"]["placement_availability_zone"][/([a-z]{2}-[a-z]+-[0-9])[a-z]/,1]
        #when adding new multi-region cloud providers - add cases here
        when nil
          false
        else
          n["cloud"]["provider"] #various single-region providers
      end rescue false # in case n["cloud"] is nil
    end

    def relative_hostname(other_node, n=node)
      if not cloud_location(n)
        n["hostname"]
      elsif cloud_location(n) == cloud_location(other_node)
        n["cloud"]["local_hostname"]
      else
        n["cloud"]["public_hostname"]
      end
    end

    def relative_ipv4(other_node, n=node)
      if not cloud_location(n)
        n["ipaddress"]
      elsif cloud_location(n) == cloud_location(other_node)
        n["cloud"]["local_ipv4"]
      else
        n["cloud"]["public_ipv4"]
      end
    end
  end
end