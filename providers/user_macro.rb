action :create do
  # Template file
  template_file = node["check_mk"]["server"]["paths"]["nagios_resource_file"]

  # The magic!
  begin
    t = resources(:template => template_file)

    # Warn if we are about to override a previously configured USER macro
    log "Nagios macro '#{new_resource.number} was overridden" do
      level :warn
      only_if { t.variables[:plugins][new_resource.number] }
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
  t.variables[:macros][new_resource.number] = new_resource.value

  new_resource.updated_by_last_action(@current_resources_cfg.find {|s| s == new_resource_expected_line})
end

def load_current_resource
  @current_resources_cfg = read_resources_cfg
end

def new_resource_expected_line
  "$USER#{new_resource.number}$=#{new_resource.value}\n"
end

def read_resources_cfg
  ::File.open node["check_mk"]["server"]["paths"]["nagios_resource_file"] do |file|
    file.readlines
  end
end