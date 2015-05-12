module SimpleFilter
  module Helpers
    module FormHelper

      def filter_form_for(filter_object, options = {}, &block)
        options||={}
        style = (options[:style] || 'horizontal').to_sym

        render 'simple_filter/form', style: style, filter_object: filter_object
      end

      def horizontal_filter_form_for(filter_object, options = {}, &block)
        options[:style]=:horizontal
        filter_form_for filter_object, options, &block
      end


      def inline_filter_form_for(filter_object, options = {}, &block)
        options[:style]=:inline
        filter_form_for filter_object, options, &block
      end

=begin
    def old_filter_form_for(filter_object, options = {}, &block)
      options[:html] ||= {}

      options[:url] = send(filter_object.url)

      options[:html][:role] = 'form'

      # class
      options[:html][:class] ||= []
      if options[:html][:class].is_a? String
        options[:html][:class] = [options[:html][:class]]
      end
      options[:html][:class] << 'form-inline'
      options[:html][:id] = 'formFilter'

      options[:wrapper] = :inline_search_form
      options[:wrapper_mappings] = {      }


      capture do
        simple_form_for(:filter, options) do |f|
          concat(hidden_field_tag 'cmd', 'apply')
          concat(render 'simple_filter/filter_fields', filter: filter_object, f: f)
          concat(render 'simple_filter/buttons_apply_clear_inline', filter: filter_object, f: f)
        end
      end

    end
=end


      def link_to_sortable_column(field_name, title = nil, html_options = nil, &block)
        html_options ||= {}
        #html_options[:method] = @filter.form_method
        url = send(@filter.url, @filter.url_params_for_sortable_column(field_name))

        link_to(title, url, html_options)
      end


    end
  end
end
