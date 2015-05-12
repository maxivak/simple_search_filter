require 'simple_filter/helpers/form_helper'

module SimpleFilter
  module Helpers
    #autoload :SearchFormHelper,  'simple_filter/helpers/search_form_helper'
    #include SimpleFilter::Helpers::SearchFormHelper

    extend ActiveSupport::Concern

    included do
      include SimpleFilter::Helpers::FormHelper

    end
  end
end