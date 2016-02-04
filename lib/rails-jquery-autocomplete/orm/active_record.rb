module RailsJQueryAutocomplete
  module Orm
    module ActiveRecord
      def active_record_get_autocomplete_order(method, options, model=nil)
        order = options[:order]

        table_prefix = model ? "#{model.table_name}." : ""
        if sqlite?
          order || "LOWER(#{method}) ASC"
        else
          order || "LOWER(#{table_prefix}#{method}) ASC"
        end
      end

      def active_record_get_autocomplete_items(parameters)
        model   = parameters[:model]
        term    = parameters[:term]
        options = parameters[:options]
        method  = options[:hstore] ? options[:hstore][:method] : parameters[:method]
        scopes  = Array(options[:scopes])
        where   = options[:where]
        limit   = get_autocomplete_limit(options)
        order   = active_record_get_autocomplete_order(method, options, model)

        items = (::Rails::VERSION::MAJOR * 10 + ::Rails::VERSION::MINOR) >= 40 ? model.where(nil) : model.scoped

        scopes.each { |scope| items = items.send(scope) } unless scopes.empty?

        select_method = options[:select_method] || :select

        if select_method == :select
          items = items.select(get_autocomplete_select_clause(model, method, options)) unless options[:full_model]
        end
        items = items.where(get_autocomplete_where_clause(model, term, method, options)).
            limit(limit).order(order)
        items = items.where(where) unless where.blank?
        if select_method == :pluck
          columns = get_autocomplete_select_clause(model, method, options)
          items = items.pluck(*columns) unless options[:full_model]
          columns = columns.map{|column| column.sub(/^#{model.table_name}\./, '')}
          items = items.map{|item| Hash[columns.zip(item)]}
        end
        items
      end

      def get_autocomplete_select_clause(model, method, options)
        if sqlite?
          table_name = model.quoted_table_name
          ([
              "#{table_name}.#{model.connection.quote_column_name(model.primary_key)} as #{model.primary_key}",
              "#{table_name}.#{model.connection.quote_column_name(method)} as #{method}"
            ] + (options[:extra_data].blank? ? [] : options[:extra_data]))
        else
          table_name = model.table_name
          (["#{table_name}.#{model.primary_key}", "#{table_name}.#{method}"] + (options[:extra_data].blank? ? [] : options[:extra_data]))
        end
      end

      def get_autocomplete_where_clause(model, term, method, options)
        table_name = model.table_name
        is_full_search = options[:full]
        is_case_sensitive_search = options[:case_sensitive]
        like_clause = (postgres?(model) && !is_case_sensitive_search ? 'ILIKE' : 'LIKE')
        column_transform = is_case_sensitive_search ? '' : 'LOWER'
        if options[:hstore]
          ["#{column_transform}(#{table_name}.#{method} -> '#{options[:hstore][:key]}') LIKE #{column_transform}(?)", "#{(is_full_search ? '%' : '')}#{term}%"]
        elsif sqlite?
          ["#{column_transform}(#{method}) #{like_clause} #{column_transform}(?)", "#{(is_full_search ? '%' : '')}#{term}%"]
        else
          ["#{column_transform}(#{table_name}.#{method}) #{like_clause} #{column_transform}(?)", "#{(is_full_search ? '%' : '')}#{term}%"]
        end
      end

      protected

        def sqlite?
          begin
            return ::ActiveRecord::Base.connection.to_s.match(/SQLite/)
          rescue ::ActiveRecord::ConnectionNotEstablished
            return false
          end
          return false
        end

        def postgres?(model)
          # Figure out if this particular model uses the PostgreSQL adapter
          model.connection.class.to_s.match(/PostgreSQLAdapter/)
        end
    end
  end
end
