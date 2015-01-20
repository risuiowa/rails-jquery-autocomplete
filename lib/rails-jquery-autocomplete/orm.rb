module RailsJQueryAutocomplete
  module Orm
    autoload :ActiveRecord , 'rails-jquery-autocomplete/orm/active_record'
		autoload :Mongoid      , 'rails-jquery-autocomplete/orm/mongoid'
		autoload :MongoMapper  , 'rails-jquery-autocomplete/orm/mongo_mapper'
  end
end

