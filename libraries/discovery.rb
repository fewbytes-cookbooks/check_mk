module Check_MK
  module Discovery
    def register_agent
      register 'agent'
    end

    def register_server
      register 'server'
    end

    def agents
      if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
        [node]
      else
        search(:node, "check_mk_discovery_provides:agent AND (#{environments})")
      end
    end

    def servers
      if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
        [node]
      else
        search(:node, "check_mk_discovery_provides:server AND (#{environments})")
      end
    end

    def environments
      (node['check_mk']['scope'] || [node.chef_environment]).map do |e|
        "chef_environment:#{e}"
      end.join(' OR ')
    end

    def register(service)
      node.override['check_mk']['discovery']['provides'] = [] unless node.override['check_mk']['discovery']['provides'].is_a? Array
      unless node['check_mk']['discovery']['provides'].include?(service)
        node.override['check_mk']['discovery']['provides'] << service
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

    def search_data_bag(*args)
      search(*args)
    rescue Net::HTTPServerException => e
      if e.data.code_type == Net::HTTPNotFound
        ::Chef::Log.warn("#{args.first} data bag does not exist. Please create it.")
        []
      else
        raise e
      end
    end
  end
end
