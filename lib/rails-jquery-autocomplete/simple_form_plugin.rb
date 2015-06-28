module SimpleForm
  module Inputs
    module Autocomplete
      #
      # Method used to rename the autocomplete key to a more standard
      # data-autocomplete key
      #
      def rewrite_autocomplete_option
        new_options = {}
        new_options["data-autocomplete-fields"] = JSON.generate(options.delete :fields) if options[:fields]
        new_options["data-update-elements"] = JSON.generate(options.delete :update_elements) if options[:update_elements]
        new_options["data-id-element"] = options.delete :id_element if options[:id_element]
        input_html_options.merge new_options
      end
    end

    class AutocompleteInput < Base
      include Autocomplete

      protected
      def limit
        column && column.limit
      end

      def has_placeholder?
        placeholder_present?
      end

      def input(args = nil)
        # This branching is to deal with a change beginning in simple_form 3.0.2 and above to ensure backwards compatibility
        if args.nil?
          @builder.autocomplete_field(
            attribute_name,
            options[:url],
            rewrite_autocomplete_option
          )
        else
          @builder.autocomplete_field(
            attribute_name,
            options[:url],
            merge_wrapper_options(rewrite_autocomplete_option, args)
          )
        end
      end
    end

    class AutocompleteCollectionInput < CollectionInput
      include Autocomplete

      def input(opts)
        # http://www.codeofficer.com/blog/entry/form_builders_in_rails_discovering_field_names_and_ids_for_javascript/
        hidden_id = "#{object_name}_#{attribute_name}_hidden".gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
        id_element = options[:id_element]
        if id_element
          id_element << ", #" << hidden_id
        else
          id_element = "#" + hidden_id
        end
        options[:id_element] = id_element

        # This branching is to deal with a change beginning in simple_form 3.0.2 and above to ensure backwards compatibility
        if opts.nil?
          autocomplete_options = rewrite_autocomplete_option
        else
          merge_wrapper_options(rewrite_autocomplete_option, args)
        end

        label_method, value_method = detect_collection_methods
        association = object.send(reflection.name)
        if association && association.respond_to?(label_method)
          autocomplete_options[:value] = association.send(label_method)
        end
        out = @builder.autocomplete_field(
          attribute_name,
          options[:url],
          autocomplete_options
        )
        hidden_options = if association && association.respond_to?(value_method)
          new_options = {}
          new_options[:value] = association.send(value_method)
          input_html_options.merge new_options
        else
          input_html_options
        end
        hidden_options[:id] = hidden_id
        out << @builder.hidden_field(
          attribute_name,
          hidden_options
        )
        out.html_safe
      end
    end
  end

  class FormBuilder
    map_type :autocomplete, :to => SimpleForm::Inputs::AutocompleteInput
    map_type :autocomplete_collection, :to => SimpleForm::Inputs::AutocompleteCollectionInput
  end

end
