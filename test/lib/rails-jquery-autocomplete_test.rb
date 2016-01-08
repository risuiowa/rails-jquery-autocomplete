require 'test_helper'

module RailsJQueryAutocomplete
  class RailsJQueryAutocompleteTest < ActionController::TestCase
    ActorsController = Class.new(ActionController::Base)
    ActorsController.autocomplete(:action_name, { :movie => :name }, { :display_value => :name })

    class ::Movie ; end

    context '#autocomplete_object_method' do
      setup do
        @controller = ActorsController.new
        @items = {}
        @options = { :display_value => :name }
      end

      should 'respond to the action' do
        assert_respond_to @controller, :autocomplete_action_name
      end

      should 'render the JSON items' do
        mock(@controller).get_autocomplete_items(
            { :model => Movie, :options => @options, :term => "query", :method => :name }
        ) { @items }

        mock(@controller).json_for_autocomplete(@items, :name, nil)
        get :autocomplete_action_name, :term => 'query'
      end

      context 'no term is specified' do
        should "render an empty hash" do
          # mock(@controller).json_for_autocomplete(nil, {}, :name, nil)
          get :autocomplete_action_name
        end
      end
    end
  end
end
