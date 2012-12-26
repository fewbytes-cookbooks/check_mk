define :check_mk_mrpe_plugin, :plugin => nil, :path => nil, :arguments => "" do
  # Must have path attribute
  raise ::Chef::Exceptions::InvalidResourceSpecification,
    "Must provide path for plugin" unless params[:path]

  # Name attribute is plugin
  plugin_name = params[:plugin] || params[:name]

  # Template file
  template_file = node['check_mk']['agent']['mrpe']

  # Used to check if we created this call created the template resource
  warn_if_exists = true

  # The magic!
  begin
    t = resources(:template => template_file)
  rescue ArgumentError, ::Chef::Exceptions::ResourceNotFound
    warn_if_exists = false

    template template_file do
      owner "root"
      group "root"
      mode "0644"
      cookbook "check_mk"
      variables(
        :plugins => {
          plugin_name => {
            :path => params[:path],
            :arguments => params[:arguments]
          }
        }
      )
    end
    retry
  end

  # Warn if we are about to override a previously configured MRPE plugin
  log "Check_MK MRPE plugin was overridden #{plugin_name}" do
    level :warn
    only_if { warn_if_exists and t.variables[:plugins][plugin_name] }
  end

  # Add a plugin or set an existing one
  t.variables[:plugins][plugin_name] = {
    :path => params[:path],
    :arguments => params[:arguments]
  }
end