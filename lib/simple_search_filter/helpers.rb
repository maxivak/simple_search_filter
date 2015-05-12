require 'simple_search_filter/helpers/form_helper'

module SimpleSearchFilter
  module Helpers
    #autoload :SearchFormHelper,  'simple_search_filter/helpers/search_form_helper'
    #include SimpleSearchFilter::Helpers::SearchFormHelper

    extend ActiveSupport::Concern

    included do
      include SimpleSearchFilter::Helpers::FormHelper

    end
  end
end