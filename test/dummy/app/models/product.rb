class Product < ActiveRecord::Base
  belongs_to :category

  paginates_per 3

  searchable_by_simple_filter
end
