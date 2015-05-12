class Product < ActiveRecord::Base

  paginates_per 3

  searchable_by_simple_filter
end
