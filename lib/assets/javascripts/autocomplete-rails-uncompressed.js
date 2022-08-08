/*
* Unobtrusive autocomplete
*
* To use it, you just have to include the HTML attribute autocomplete
* with the autocomplete URL as the value
*
*   Example:
*       <input type="text" data-autocomplete="/url/to/autocomplete">
*
* Optionally, you can use a jQuery selector to specify a field that can
* be updated with the element id whenever you find a matching value
*
*   Example:
*       <input type="text" data-autocomplete="/url/to/autocomplete" data-id-element="#id_field">
*/

(function(jQuery)
{
  var self = null;
  jQuery.fn.railsAutocomplete = function(selector) {
    var handler = function() {
      if (!this.railsAutoCompleter) {
        this.railsAutoCompleter = new jQuery.railsAutocomplete(this);
      }
    };
    if (jQuery.fn.on !== undefined) {
      if (!selector) {
        return;
      }
      return jQuery(document).on('focus',selector,handler);
    }
    else {
      return this.live('focus',handler);
    }
  };

  jQuery.railsAutocomplete = function (e) {
    var _e = e;
    this.init(_e);
  };
  jQuery.railsAutocomplete.options = {
    showNoMatches: true,
    noMatchesLabel: 'no existing match'
  }

  jQuery.railsAutocomplete.fn = jQuery.railsAutocomplete.prototype = {
    railsAutocomplete: '0.0.1'
  };

  jQuery.railsAutocomplete.fn.extend = jQuery.railsAutocomplete.extend = jQuery.extend;
  jQuery.railsAutocomplete.fn.extend({
    init: function(e) {
      e.delimiter = jQuery(e).attr('data-delimiter') || null;
      e.min_length = jQuery(e).attr('data-min-length') || jQuery(e).attr('min-length') || 2;
      e.append_to = jQuery(e).attr('data-append-to') || null;
      e.autoFocus = jQuery(e).attr('data-auto-focus') || false;
      function split( val ) {
        return val.split( e.delimiter );
      }
      function extractLast( term ) {
        return split( term ).pop().replace(/^\s+/,"");
      }

      jQuery(e).autocomplete({
        appendTo: e.append_to,
        autoFocus: e.autoFocus,
        delay: jQuery(e).attr('delay') || 0,
        source: function( request, response ) {
          var firedFrom = this.element[0];
          var params = {term: extractLast( request.term )};
          if (jQuery(e).attr('data-autocomplete-fields')) {
              jQuery.each(jQuery.parseJSON(jQuery(e).attr('data-autocomplete-fields')), function(field, selector) {
              params[field] = jQuery(selector).val();
            });
          }
          jQuery.getJSON( jQuery(e).attr('data-autocomplete'), params, function() {
            var options = {};
            jQuery.extend(options, jQuery.railsAutocomplete.options);
            jQuery.each(options, function(key, value) {
              if(options.hasOwnProperty(key)) {
                var attrVal = jQuery(e).attr('data-' + key);
                options[key] = attrVal ? attrVal : value;
              }
            });
            if(arguments[0].length == 0 && jQuery.inArray(options.showNoMatches, [true, 'true']) >= 0) {
              arguments[0] = [];
              arguments[0][0] = { id: "", label: options.noMatchesLabel };
            }
            jQuery(arguments[0]).each(function(i, el) {
              var obj = {};
              obj[el.id] = el;
              jQuery(e).data(obj);
            });
            response.apply(null, arguments);
            jQuery(firedFrom).trigger('railsAutocomplete.source', arguments);
          });
        },
        change: function( event, ui ) {
            if(!jQuery(this).is('[data-id-element]') ||
                    jQuery(jQuery(this).attr('data-id-element')).val() === "") {
                    return;
            }
            jQuery(jQuery(this).attr('data-id-element')).val(ui.item ? ui.item.id : "").trigger('change');

            if (jQuery(this).attr('data-update-elements')) {
                var update_elements = jQuery.parseJSON(jQuery(this).attr("data-update-elements"));
                var data = ui.item ? jQuery(this).data(ui.item.id.toString()) : {};
                if(update_elements && jQuery(update_elements['id']).val() === "") {
                  return;
                }
                for (var key in update_elements) {
                    var element = jQuery(update_elements[key]);
                    if (element.is(':checkbox')) {
                        if (data[key] != null) {
                            element.prop('checked', data[key]);
                        }
                    } else {
                        element.val(ui.item ? data[key] : "").trigger('change');
                    }
                }
            }
        },
        search: function() {
          // custom minLength
          var term = extractLast( this.value );
          if ( term.length < 1 ) {
            return false;
          }
        },
        focus: function() {
          // prevent value inserted on focus
          return false;
        },
        select: function( event, ui ) {
          // first ensure value is a string
          ui.item.value = ui.item.value.toString();
          if(ui.item.value.toLowerCase().indexOf('no match') != -1 || ui.item.value.toLowerCase().indexOf('too many results') != -1){
            jQuery(this).trigger('railsAutocomplete.noMatch', ui);
            return false;
          }
          var terms = split( this.value );
          // remove the current input
          terms.pop();
          // add the selected item
          terms.push( ui.item.value );
          // add placeholder to get the comma-and-space at the end
          if (e.delimiter != null) {
            terms.push( "" );
            this.value = terms.join( e.delimiter );
          } else {
            this.value = terms.join("");
            if (jQuery(this).attr('data-id-element')) {
              jQuery(jQuery(this).attr('data-id-element')).val(ui.item.id).trigger('change');
            }
            if (jQuery(this).attr('data-update-elements')) {
              var data = ui.item;
              var new_record = ui.item.value.indexOf('Create New') != -1 ? true : false;
              var update_elements = jQuery.parseJSON(jQuery(this).attr("data-update-elements"));
              for (var key in update_elements) {
                if(jQuery(update_elements[key]).attr("type") === "checkbox"){
                   if(data[key] === true || data[key] === 1) {
                       jQuery(update_elements[key]).attr("checked","checked");
                   }
                   else {
                       jQuery(update_elements[key]).removeAttr("checked");
                   }
                }
                else{
                  if((new_record && data[key] && data[key].indexOf('Create New') == -1) || !new_record){
                    jQuery(update_elements[key]).val(data[key]).trigger('change');
                  }else{
                    jQuery(update_elements[key]).val('').trigger('change');
                  }
                }
               }
            }
          }
          var remember_string = this.value;
          jQuery(this).bind('keyup.clearId', function(){
            if(jQuery.trim(jQuery(this).val()) != jQuery.trim(remember_string)){
              jQuery(jQuery(this).attr('data-id-element')).val("").trigger('change');
              jQuery(this).unbind('keyup.clearId');
            }
          });
          jQuery(e).trigger('railsAutocomplete.select', ui);

          return false;
        }
      });
      jQuery(e).trigger('railsAutocomplete.init');
    }
  });

  jQuery(document).ready(function(){
    jQuery('input[data-autocomplete]').railsAutocomplete('input[data-autocomplete]');
  });
})(jQuery);
