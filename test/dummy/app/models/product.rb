class Product < ActiveRecord::Base
  belongs_to :category

  paginates_per 3

  searchable_by_simple_filter

  scope :archived, lambda {  |include_archived| where(is_archived: false) if !include_archived}

  scope :of_category, lambda {  |category_id| where_category(category_id) }


  def self.where_category(id)
    v = (id.to_i rescue 0)
    if v>0
      where(category_id: id)
    else
      where("1=1")
    end
  end


end
