class OrdersController < ApplicationController

  # POST, save in session

  search_filter :index, {save_session: true, search_method: :post_and_redirect, url: :orders_path, search_url: :search_orders_path, search_action: :search} do
    default_order "id", 'desc'

    # custom scope
    field :city, :string,  :text, {label: 'City', default_value: '', ignore_value: '', search_by: :id, condition: :custom, condition_scope: :of_client_city}

  end


  def index
    @items = Order.includes(:client).by_filter(@filter)

  end


end