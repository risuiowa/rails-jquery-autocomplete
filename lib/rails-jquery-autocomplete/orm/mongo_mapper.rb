module RailsJQueryAutocomplete
	module Orm
		module MongoMapper
			def mongo_mapper_get_autocomplete_order(method, options, model=nil)
        order = options[:order]
        if order
          order.split(',').collect do |fields|
            sfields = fields.split
            [sfields[0].downcase.to_sym, sfields[1].downcase.to_sym]
          end
        else
          [[method.to_sym, :asc]]
        end
			end

			def mongo_mapper_get_autocomplete_items(parameters)
        model          = parameters[:model]
        method         = parameters[:method]
        options        = parameters[:options]
        is_full_search = options[:full]
        is_case_sensitive_search = options[:case_sensitive]
        term           = parameters[:term]
        limit          = get_autocomplete_limit(options)
        order          = mongo_mapper_get_autocomplete_order(method, options)

        search = (is_full_search ? '.*' : '^') + term + '.*'
        search = Regexp.new(search, !is_case_sensitive_search)
				items  = model.where(method.to_sym => search).limit(limit).sort(order)
			end
		end
	end
end
