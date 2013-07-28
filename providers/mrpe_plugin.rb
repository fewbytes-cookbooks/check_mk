action :create do
  # Template file
  template_file = node['check_mk']['agent']['mrpe']

  _path = new_resource.path
  _arguments = new_resource.arguments
  _plugin = new_resource.plugin

  # The magic!
  t = begin
    _t = resource_collection.find(:template => template_file)

    # Warn if we are about to override a previously configured MRPE plugin
    Chef::Log.warn "Check_MK MRPE plugin '#{new_resource.plugin} will be overridden" if _t.variables.has_key?(:plugins) \
      and _t.variables[:plugins].has_key?(_plugin)
    _t
  rescue ArgumentError, ::Chef::Exceptions::ResourceNotFound
    template template_file do
      owner "root"
      group "root"
      mode "0644"
      cookbook "check_mk"
      variables :plugins => Hash.new
    end
  end

  # Add a plugin or set an existing one
  _plugins = t.variables.fetch(:plugins, Hash.new).merge(_plugin => {
    :path => _path,
    :arguments => _arguments
  })
  t.variables t.variables.merge(:plugins => _plugins)

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