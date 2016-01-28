class Order < ActiveRecord::Base
  belongs_to :client

  # search
  searchable_by_simple_filter

  scope :of_client_city, lambda {  |city| where_client_city(city) }

  def self.where_client_city(v)
    if v.present?
      where(client_id: Client.select("id").where(:city => v))
    else
      where("1=1")
    end
  end


  #
  scope :of_category, lambda {  |category_id| where_category(category_id) }

  def self.where_category(id)
    v = (id.to_i rescue 0)
    if v>0
      where(product_id: Product.select("id").where(:category_id => id))
    else
      where("1=1")
    end
  end

end