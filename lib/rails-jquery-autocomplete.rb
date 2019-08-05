require 'rails-jquery-autocomplete/form_helper'
require 'rails-jquery-autocomplete/autocomplete'

module RailsJQueryAutocomplete
  autoload :Orm              , 'rails-jquery-autocomplete/orm'
  autoload :FormtasticPlugin , 'rails-jquery-autocomplete/formtastic_plugin'

  unless ::Rails.version < "3.1"
    require 'rails-jquery-autocomplete/rails/engine'
  end
end

if Rails::VERSION::MAJOR >= 6
  ActiveSupport.on_load(:action_controller_base) do
    ActionController::Base.send(
      :include,
      RailsJQueryAutocomplete::Autocomplete
    )
  end
else
  ActionController::Base.send(:include, RailsJQueryAutocomplete::Autocomplete)
end

require 'rails-jquery-autocomplete/formtastic'

begin
  require 'simple_form'
  require 'rails-jquery-autocomplete/simple_form_plugin'
rescue LoadError
end
