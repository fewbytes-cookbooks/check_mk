action :create do
  # Template file
  template_file = node['check_mk']['agent']['mrpe']

  # The magic!
  begin
    t = resources(:template => template_file)

    # Warn if we are about to override a previously configured MRPE plugin
    log "Check_MK MRPE plugin '#{new_resource.plugin} was overridden" do
      level :warn
      only_if { t.variables[:plugins][new_resource.plugin] }
    end
  rescue ArgumentError, ::Chef::Exceptions::ResourceNotFound
    template template_file do
      owner "root"
      group "root"
      mode "0644"
      cookbook "check_mk"
    end
    retry
  end

  # Add a plugin or set an existing one
  t.variables[:plugins][new_resource.plugin] = {
    :path => params[new_resource.path],
    :arguments => params[new_resource.arguments]
  }

  new_resource.updated_by_last_action(@current_mrpe_cfg.find {|s| s == new_resource_expected_line})
end

def load_current_resource
  @current_mrpe_cfg = read_mrpe_cfg
end

def new_resource_expected_line
  "#{new_resource.plugin} #{new_resource.path} #{new_resource.arguments}\n"
end

def read_mrpe_cfg
  ::File.open node['check_mk']['agent']['mrpe'] do |file|
    file.readlines
  end
end