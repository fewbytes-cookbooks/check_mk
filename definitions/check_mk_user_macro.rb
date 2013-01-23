define :check_mk_user_macro, :number => nil, :value => nil do
  # Must have path attribute
  raise ::Chef::Exceptions::InvalidResourceSpecification,
    "Must provide value" unless params[:value]

  # Name attribute is number
  user_macro_number = params[:number] || params[:name]

  # Template file
  template_file = node["check_mk"]["server"]["paths"]["nagios_resource_file"]

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
        :macros => {
          user_macro_number => params[:value]
        }
      )
    end
    retry
  end

  # Warn if we are about to override a previously configured MRPE plugin
  log "Check_MK USER macro #{user_macro_number} overridden" do
    level :warn
    only_if { warn_if_exists and t.variables[:macros][user_macro_number] }
  end

  # Add a plugin or set an existing one
  t.variables[:macros][user_macro_number] = params[:value]
end