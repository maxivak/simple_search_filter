require 'simple_search_filter/models/searchable_class_methods'

class << ActiveRecord::Base

  def searchable_by_simple_filter(options={})
    extend SimpleSearchFilter::Models::SearchableClassMethods

    scope :by_filter, ->(filter, options={}) { make_search_by_filter(filter, options) }

  end

end


