class DemosController < ApplicationController

  #include SimpleFilter::Controller
  search_filter :basic_index, {save_session: true, search_method: :post_and_redirect, search_url: :search_basic_demo_url, search_action: :basic_search} do
    # define filter
    default_order "title", 'asc'

    # fields
    field :title, :string, :text, {label: '', default_value: '', condition: :like_full}

  end



  def basic_index
    f = @filter

    x = (self.respond_to? :init_search_filter_basic) ? 1 : 0

    logger.debug "f=#{@filter.inspect}, x=#{x}"


    x=0


  end
end