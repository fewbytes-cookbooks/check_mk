actions :create
default_action :create

# :plugin should not contain any spaces
attribute :plugin, regex: /^[^\s]*$/, name_attribute: true
attribute :path,   kind_of: String, required: true
attribute :arguments, kind_of: String
