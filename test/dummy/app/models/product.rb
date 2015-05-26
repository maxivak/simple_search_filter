class Product < ActiveRecord::Base
  belongs_to :category

  paginates_per 3

  searchable_by_simple_filter

  scope :archived, lambda {  |include_archived| where(is_archived: false) if !include_archived}


end
