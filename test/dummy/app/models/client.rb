class Client < ActiveRecord::Base
  has_many :orders

  # search
  searchable_by_simple_filter

  scope :bought_product, lambda {  |product_id| where_bought_product(product_id) }

  def self.where_bought_product(product_id)
    v = (product_id.to_i rescue 0)
    if v>0
      where(:order_id => DeviceModel.select("id").where(:device_brand_id => id))
    else
      where("1=1")
    end
  end


end