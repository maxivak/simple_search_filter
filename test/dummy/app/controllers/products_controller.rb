class ProductsController < ApplicationController

=begin
  search_filter :index, {save_session: true, search_method: :post_and_redirect, search_url: :search_templates_url, search_action: :search} do
    # define filter
    default_order "title", 'asc'

    # fields
    field :title, :string, :text, {label: '', default_value: '', condition: :like_full}
    #field :parent_id, :int, :hidden, {label: '', default_value: 0, ignore_value: 0, condition: :empty}
    field :parent_id, :int, :hidden, {label: '', default_value: 0, ignore_value: 0, condition: :custom, condition_scope: :of_parent}

    #field :category_id, :int, :select, {collection: [['USD',1],['CAD',2]], label_method: :first, value_method: :last}
    #field :type_id, :int, :select, {label: 'Type', default_value: 0, collection: TemplateType.all, label_method: :title, value_method: :id}
    #field :type, :string, :autocomplete, {label: 'Type', default_value: '', :source_query => :autocomplete_templates_url}

  end
=end

  # GET
=begin
  search_filter :index, {url: :products_path} do
    default_order "price", 'asc'

    field :title, :string, :text, {label: 'Title', default_value: '', condition: :like_full}
  end
=end


  # POST, save in session

  search_filter :index, {save_session: true, search_method: :post_and_redirect, url: :products_path, search_url: :search_products_path, search_action: :search} do
    default_order "price", 'asc'

    field :title, :string, :text, {label: 'Title', default_value: '', condition: :like_full, input_html: {style: "width: 240px"} }
    field :price_from, :string, :text, {label: 'Price', default_value: '', condition: :custom, condition_where: 'price >= ?', input_html: {style: "width: 140px"} }
    field :price_to, :string, :text, {label: 'to', default_value: '', condition: :custom, condition_where: 'price <= ?', input_html: {style: "width: 140px"} }

    #field :category_id, :int,  :select, {label: 'Category', default_value: 0, ignore_value: 0, collection: Category.all, label_method: :title, value_method: :id, include_blank: true }
    field :category, :string,  :autocomplete, {label: 'Category', default_value: '', ignore_value: '', search_by: :id, source_query: :autocomplete_category_title_categories_path}

    field :archived, :boolean,  :checkbox, {label: 'Include archived', default_value: false, ignore_value: true, condition: :custom, condition_scope: :archived}

    field :user_id, :int,  :hidden, {label: '', default_value: 0, ignore_value: 0, condition: :empty}

  end


  def index

    # set value in filter explicitly
    @filter.set 'user_id', 101

    # use model.search_by_filter
    #@items = Product.by_filter(@filter)
    @items = Product.includes(:category).by_filter(@filter)

    # use filter.where
    #@items = Product.where(@filter.where).order(@filter.order_string).page(@filter.page)

    # use filter values in where
    #category_id = @filter.v(:category_id)
    #Product.where(:category_id=>category_id)



  end


end