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
  end
end