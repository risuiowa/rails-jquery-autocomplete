## Status

1. This is the officially maintained fork of
   [rails3-jquery-autocomplete](http://github.com/crowdint/rails3-jquery-autocomplete)
2. All new features and support of Rails 4 and above will occur here
   going forward.  Rails 3 is also supported on this fork; bug fixes and security fixes for Rails 3 will continue until Rails 3 is EOL.

# rails-jquery-autocomplete

[![Build Status](https://secure.travis-ci.org/bigtunacan/rails-jquery-autocomplete.png)](http://travis-ci.org/bigtunacan/rails-jquery-autocomplete) [![Gem Version](https://badge.fury.io/rb/rails-jquery-autocomplete.png)](http://badge.fury.io/rb/rails-jquery-autocomplete)

An easy way to use jQuery's autocomplete with Rails.

Supports both ActiveRecord, [mongoid](https://github.com/mongodb/mongoid), and [MongoMapper](https://github.com/jnunemaker/mongomapper).

Works with [Formtastic](http://github.com/justinfrench/formtastic)
and [SimpleForm](https://github.com/plataformatec/simple_form)

## ActiveRecord

You can find a [detailed example](http://github.com/crowdint/rails3-jquery-autocomplete-app)
on how to use this gem with ActiveRecord [here](http://github.com/crowdint/rails3-jquery-autocomplete-app).

## MongoID

You can find a [detailed example](http://github.com/crowdint/rails3-jquery-autocomplete-app/tree/mongoid)
on how to use this gem with MongoID [here](http://github.com/crowdint/rails3-jquery-autocomplete-app/tree/mongoid). (Same thing, different branch)

## Before you start

Make sure your project is using jQuery-UI and the autocomplete widget
before you continue.

You can find more info about that here:

* http://jquery.com/
* http://jqueryui.com/demos/autocomplete/
* http://github.com/rails/jquery-ujs

I'd encourage you to understand how to use those 3 amazing tools before attempting to use this gem.

## Installing

Include the gem on your Gemfile

    gem 'rails-jquery-autocomplete'

Install it

    bundle install

### Rails < 4.x.x

Run the generator

    rails generate autocomplete:install

And include autocomplete-rails.js on your layouts

    javascript_include_tag "autocomplete-rails.js"

#### Upgrading from older versions

If you are upgrading from a previous version, run the generator after installing to replace the javascript file.

    rails generate autocomplete:install

I'd recommend you do this every time you update to make sure you have the latest JS file.

#### Uncompressed Javascript file

If you want to make changes to the JS file, you can install the
uncompressed version by running:

    rails generate autocomplete:uncompressed

### Rails 4 and higher

Just add it to your app/assets/javascripts/application.js file

    //= require jquery
    //= require jquery_ujs
    //= require jquery-ui/widgets/autocomplete
    //= require autocomplete-rails

## Usage

### Demo Application by [Yifei](https://github.com/yifeiwu)

A live demo can be seen

[here](https://rocky-thicket-9286.herokuapp.com/)

[source](https://github.com/yifeiwu/rails4-autocomplete-demo)

As a new developer, I had some issues getting this to work by following the documentation. However after trying some things and reading [Yoni Weisbrod](http://www.yoniweisbrod.com/autocomplete-magic-with-rails/)'s blog post, I was able to make the autocomplete work and implement a few useful features.

##Some implemented features

1. The css has been changed such that the results show up better against the box of suggestions. See  `<app/assets/stylesheets/food.scss>` for details. I obtained this from a gist(forgive me I don't remember who the author is at the moment, please contact me if you do and I'll give credit). Upon mouseover/arrowkey presses, the selection will be highlighted.

2. One Yoni's improvements, you can click on a suggested item to submit the search, instead of having to click on the submit button after clicking on the item. This is an example of how to hook onto the *railsAutocomplete.select* event.

3. The autocomplete is implemented in the context of a search form with a simple scope search(see the food model and controller).

### Model Example

Assuming you have a Brand model that contains a name attribute:

    class Brand < ActiveRecord::Base
    end

    create_table :brand do |t|
      t.column :name, :string
    end

### Controller

To set up the required action on your controller, all you have to do is call it with the class name and the method
as in the following example:

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name
    end

This will create an action _autocomplete_brand_name_ on your controller, don't forget to add it on your routes file

    resources :products do
      get :autocomplete_brand_name, :on => :collection
    end

Verify this path using `rake routes`, you will need it later for the **view** section.

### Options

#### :full => true

By default, the search starts from the beginning of the string you're searching for. If you want to do a full search, set the _full_ parameter to true.

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :full => true
    end

The following terms would match the query 'un':

* Luna
* Unacceptable
* Rerun

#### :full => false (default behavior)

Only the following terms would match the query 'un':

* Unacceptable

#### :limit => 10 (default behavior)

By default your search result set is limited to the first 10 records. This can be overridden by specifying the limit option.

#### :extra_data

By default, your search will only return the required columns from the database needed to populate your form, namely id and the column you are searching (name, in the above example).

Passing an array of attributes/column names to this option will fetch and return the specified data.

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :extra_data => [:slogan]
    end

#### :display_value

If you want to display a different version of what you're looking for, you can use the :display_value option.

This options receives a method name as the parameter, and that method will be called on the instance when displaying the results.

    class Brand < ActiveRecord::Base
      def funky_method
        "#{self.name}.camelize"
      end
    end


    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :display_value => :funky_method
    end

In the example above, you will search by _name_, but the autocomplete list will display the result of _funky_method_

This wouldn't really make much sense unless you use it with the "id_element" attribute. (See below)

Only the object's id and the column you are searching on will be returned in JSON, so if your display_value method requires another parameter, make sure to fetch it with the :extra_data option

#### :hstore

Added option to support searching in hstore columns.

Pass a hash with two keys: `:method` and `:key` with values: the hstore field name and the key of the hstore to search.

e.g `autocomplete :feature, :name, :hstore => {:method => 'name_translations', :key => 'en'}`


#### :scopes

Added option to use scopes. Pass scopes in an array.
e.g `:scopes => [:scope1, :scope2]`

#### :column_name

By default autocomplete uses method name as column name. Now it can be specified using column_name options
`:column_name => 'name'`

#### :case_sensitive

Normally autocomplete performs a case insensitive search. In cases where this is not desirable, or causes too high
a performance penalty, search can be made case sensitive by specifying `:case_sensitive => true`

#### json encoder

Autocomplete uses Yajl as JSON encoder/decoder, but you can specify your own

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name do |items|
        CustomJSON::Encoder.encode(items)
      end
    end

### View

On your view, all you have to do is include the attribute autocomplete on the text field
using the url to the autocomplete action as the value.

    form_for @product do |f|
      f.autocomplete_field :brand_name, autocomplete_brand_name_products_path
    end

This will generate an HTML tag that looks like:

    <input type="text" data-autocomplete="products/autocomplete_brand_name">

If you are not using a FormBuilder (form_for) or you just want to include an autocomplete field without the form, you can use the
*autocomplete_field_tag* helper.

    form_tag 'some/path'
      autocomplete_field_tag 'address', '', address_autocomplete_path, :size => 75
    end

#### Multiple Values Separated by Delimiter

To generate an autocomplete input field that accepts multiple values separated by a given delimiter, add the `'data-delimiter'` and `:multiple` options:

    form_for @product do |f|
      f.autocomplete_field :brand_names, autocomplete_brand_name_products_path,
      'data-delimiter' => ',', :multiple => true
    end

NOTE: Setting the `:multiple` option to `true` will result in the chosen values being submitted as an array. Leaving this option off will result in the values being passed as a single string, with the values separated by your chosen delimiter.

#### Automatically focus on the first autocompleted item

To have the first item be automatically focused on when the autocomplete menu is shown, add the `'data-auto-focus'` option and set it to `true`.

    form_for @product do |f|
      f.autocomplete_field :brand_names, autocomplete_brand_name_products_path,
      'data-auto-focus' => true
    end

Now your autocomplete code is unobtrusive, Rails style.

#### Client-side config

To configure the behaviour if no matches are found, you can set the following options:

    jQuery.railsAutocomplete.options.showNoMatches //default true
    jQuery.railsAutocomplete.options.noMatchesLabel //default 'no existing match'

These will change the behaviour globally. To set them on a single input field use:

    f.autocomplete_field :brand_names, autocomplete_brand_name_products_path,
    'data-showNoMatches' => false
    #or
    f.autocomplete_field :brand_names, autocomplete_brand_name_products_path,
    'data-noMatchesLabel' => 'no brands found'


### Getting the object id

If you need to use the id of the selected object, you can use the *id_element* attribute too:

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :id_element => '#some_element'

This will update the field with id *#some_element with the id of the selected object. The value for this option can be any jQuery selector.

### Changing destination element

If you need to change destination element where the autocomplete box will be appended to, you can use the **:append_to** option which generates a **data-append-to** HTML attribute that is used in jQuery autocomplete as append_to attribute.

The :append_to option accepts a string containing jQuery selector for destination element:

    f.autocomplete_field :product_name, '/products/autocomplete_product_name', :append_to => "#product_modal"

The previous example would append the autocomplete box containing suggestions to element jQuery('#product_modal').
This is very useful on page where you use various z-indexes and you need to append the box to the topmost element, for example using modal window.

### Sending extra search fields

If you want to send extra fields from your form to the search action,
you can use the **:fields** options which generates a **data-autocomplete-fields**
HTML attribute.

The :fields option accepts a hash where the keys represent the Ajax request
parameter name and the values represent the jQuery selectors to retrieve the
form elements to get the values:

    f.autocomplete_field :product_name, '/products/autocomplete_product_name', :fields => {:brand_id => '#brand_element', :country => '#country_element'}

    class ProductsController < Admin::BaseController
      def autocomplete_product_name
        term = params[:term]
        brand_id = params[:brand_id]
        country = params[:country]
        products = Product.where('brand = ? AND country = ? AND name LIKE ?', brand_id, country, "%#{term}%").order(:name).all
        render :json => products.map { |product| {:id => product.id, :label => product.name, :value => product.name} }
      end
    end

### Getting extra object data

If you need to extra data about the selected object, you can use the *:update_elements* HTML attribute.

The :update_elements attribute accepts a hash where the keys represent the object attribute/column data to use to update and the values are jQuery selectors to retrieve the HTML element to update:

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :update_elements => {:id => '#id_element', :slogan => '#some_other_element'}

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :extra_data => [:slogan]
    end

The previous example would fetch the extra attribute slogan and update jQuery('#some_other_element') with the slogan value.

### Running custom code on selection

A javascript event named *railsAutocomplete.select* is fired on the input field when a value is selected from the autocomplete drop down. If you need to do something more complex than update fields with data, you can hook into this event, like so:

    $('#my_autocomplete_field').bind('railsAutocomplete.select', function(event, data){
      /* Do something here */
      alert(data.item.id);
    });

## Formtastic

If you are using [Formtastic](http://github.com/justinfrench/formtastic), you automatically get the *autocompleted_input* helper on *semantic_form_for*:

    semantic_form_for @product do |f|
      f.input :brand_name, :as => :autocomplete, :url => autocomplete_brand_name_products_path
    end

The only difference with the original helper is that you must specify the autocomplete url using the *:url* option.

## SimpleForm

If you want to use it with simple_form, all you have to do is use the
:as option on the input and set the autocomplete path with the :url
option.


    simple_form_for @product do |form|
      form.input :name
      form.input :brand_name, :url => autocomplete_brand_name_products_path, :as => :autocomplete

# Cucumber

I have created a step to test your autocomplete with Cucumber and Capybara, all you have to do is add the following lines to your *env.rb* file:

    require 'cucumber/autocomplete'

Then you'll have access to the following step:

    I choose "([^"]*)" in the autocomplete list

An example on how to use it:

    @javascript
    Scenario: Autocomplete
      Given the following brands exists:
        | name  |
        | Alpha |
        | Beta  |
        | Gamma |
      And I go to the home page
      And I fill in "Brand name" with "al"
      And I choose "Alpha" in the autocomplete list
      Then the "Brand name" field should contain "Alpha"

I have only tested this using Capybara, no idea if it works with something else, to see it in action, check the [example app](http://github.com/crowdint/rails3-jquery-autocomplete-app).

# Steak

I have created a helper to test your autocomplete with Steak and Capybara, all you have to do is add the following lines to your *acceptance_helper.rb* file:

    require 'steak/autocomplete'

Then you'll have access to the following helper:

    choose_autocomplete_result

An example on how to use it:

    scenario "Autocomplete" do
      lambda do
        Brand.create! [
          {:name => "Alpha"},
          {:name => "Beta"},
          {:name => "Gamma"}
        ]
      end.should change(Brand, :count).by(3)

      visit home_page
      fill_in "Brand name", :with => "al"
      choose_autocomplete_result "Alpha"
      find_field("Brand name").value.should include("Alpha")
    end

I have only tested this using Capybara, no idea if it works with something else.

# Development

If you want to make changes to the gem, first install bundler 1.0.0:

    gem install bundler

And then, install all your dependencies:

    bundle install

## Running the test suite

<strike>You need to have an instance of MongoDB running on your computer or all the mongo tests will fail miserably.</strike>

To run all the tests once, simply use

    rake test

while you're developing, it is recommended that you run

    bundle exec guard

to have the relevant test run every time you save a file.

## Integration tests

If you make changes or add features to the jQuery part, please make sure
you write a cucumber test for it.

You can find an example Rails app on the *integration* folder.

You can run the integration tests with the cucumber command while on the
integration folder:

    cd integration
    rake db:migrate
    cucumber

## Where to test what

If you're making or tweaking a plugin (such as the formtastic plugin or
simple\_form plugin), check out the simple\_form\_plugin\_test for an
example of how to test it as part of the main `rake test` run.
Historically, plugins like these had been tested (shoddily) as part of
the integration tests. Feel free to remove them from the integration
suite and move them into the main suite. Your tests will run much
faster, and there will be less likelihood of your feature breaking in
the future. Thanks!

# Thanks to

Everyone on [this list](https://github.com/crowdint/rails3-jquery-autocomplete/contributors)

