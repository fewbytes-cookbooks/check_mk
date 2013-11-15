actions :create
default_action :create

# :number should be numeric only
attribute :number, regex: /^\d+$/, name_attribute: true
attribute :value, kind_of: String, required: true
