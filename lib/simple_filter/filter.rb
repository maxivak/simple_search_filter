require 'simple_filter/filter_field'

module SimpleFilter
  class Filter
    #
    SEARCH_METHOD_GET = :get
    SEARCH_METHOD_POST_AND_REDIRECT = :post_and_redirect

    DEFAULT_SEARCH_METHOD = SEARCH_METHOD_GET

    #
    attr_accessor :prefix # session prefix
    attr_accessor :fields # array of FilterField
    attr_accessor :data # values



    def initialize(_session, _prefix, opt={})
      @prefix = _prefix
      @session = _session

      @fields ||={}

      @options = opt
      @options||={}

      # init data
      data()
    end


    def field(name, type, formtype, opt={})
      add_field FilterField.new(name,type, formtype, opt)

      if formtype.to_s==FilterField::FORM_TYPE_AUTOCOMPLETE
        opt_int = opt.clone
        opt_int[:default_value] = 0
        add_field FilterField.new(name.to_s+'_id',FilterField::TYPE_INT, FilterField::FORM_TYPE_EMPTY, opt_int)
      end

    end



    ############
    # fields
    ############

    def add_field(f)
      #@fields[f[:name]] = f
      @fields[f.name] = f

    end

    def add_fields_from_array(a)
      a.each{|fa| add_field fa}
    end


    def field_def_value(name)
      name = name.to_sym

      return nil if @fields[name].nil?

      @fields[name].default_value
    end


    ############
    # options
    ############

    def options
      @options || {}
    end

    def search_method
      options[:search_method] ||= DEFAULT_SEARCH_METHOD

      options[:search_method]
    end

    def search_method_get?
      search_method == SEARCH_METHOD_GET
    end

    def search_method_post_and_redirect?
      search_method == SEARCH_METHOD_POST_AND_REDIRECT
    end


    def url
      options[:url] || options[:search_url]
    end

    def search_url
      options[:search_url]
    end


    def form_method
      search_method_get? ? :get : :post
    end

    def page_param_name
      options[:page_param_name] || SimpleFilter.page_default_param_name
    end



    ############
    # sessions
    ############

    def session_get(name, def_value)
      @session[prefix+name] || def_value
    end

    def session_save(name, v)
      @session[prefix+name] = v
    end


    ############
    # data
    ############


    def data
      return @data unless @data.nil?

      # from session
      @data_sess = session_get 'data', nil
      unless @data_sess.nil?
        @data = @data_sess
      else

      end

      #
      @data ||= {}

      session_save('data', @data)

      #
      @data
    end

    def v(name, v_def=nil)
      name = name.to_s

      if (data.has_key? name) && (!data[name].nil?) && (!data[name].blank?)
        return data[name]
      end

      field_def_value(name) || v_def
    end


    def v_empty?(name)
      if (data.has_key? name) && (!data[name].nil?)
        return true
      end

      # if v == default value

    end

    def set(field_name,v)
      data[field_name.to_s] = @fields[field_name].fix_value(v)
    end



    def clear_data
      @data = {}
      session_save 'data', @data
    end

    def set_data_from_form(params)
      # search for fields like filter[XXX]
      params.each do |k, v|
        name = k.to_sym

        #if f =~ /^filter\[([^\]]+)\]$/
          #name = Regexp.last_match(1)

          next unless @fields.has_key? name

          if @fields[name].type==FilterField::TYPE_INT
            set name, (v.to_i rescue 0)
          else
            set name, v
          end

        #end
      end

      # default values from fields
      @fields.each do |k, f|
        name = k.to_s
        next if @data.has_key? name

        set name, field_def_value(name)
      end

    end


    ####
    # page
    ####

    def page
      return @page unless @page.nil?

      # from session
      @v_sess = session_get 'page', nil
      @page = @v_sess unless @v_sess.nil?

      #
      @page ||= 1

      session_save 'page', @page

      #
      @page
    end

    def page=(value)
      @page = value.to_i

      session_save 'page', @page
    end


    ####
    # order
    ####

    def default_order(order_by, order_dir)
      set_default_order order_by, order_dir
    end

    def order
      return @order unless @order.nil?

      # from session
      @v_sess = session_get 'order', nil
      @order = @v_sess unless @v_sess.nil?

      #
      @order ||= []

      session_save 'order', @order

      #
      @order
    end

    def order= (value)
      @order = value

      session_save 'order', @order
    end

    def set_default_order(order_by, order_dir)
      return false if !order.nil? && !order.empty?

      set_order(order_by, order_dir)

    end


    def set_order(order_by, order_dir)
      self.order = [[order_by, order_dir]]
    end

    def get_order
      order[0] if order.count>0
      order[0]
    end


    def get_opposite_order_dir_for_column(name)
      name = name.to_s

      ord = order
      return 'asc' if ord.empty?

      if ord[0][0].to_s == name
        return opposite_order_dir(ord[0][1])
      end

      return 'asc'
    end

    def opposite_order_dir(order_dir)
      order_dir = order_dir.to_s
      return 'asc' if order_dir=='desc'
      return 'desc' if order_dir=='asc'
      'asc'
    end



    def url_params_for_sortable_column(name)
      p = {}
      p[:cmd] = 'order'
      p[:orderby] = name.to_s
      p[:orderdir] = get_opposite_order_dir_for_column(name)

      p
    end



    ########
    # where
    ########

    def order_string
      o = order
      if o.empty?
        orderby = 'id'
        orderdir = 'asc'
      else
        orderby, orderdir = order[0]
      end

      "#{orderby} #{orderdir}"
    end



    def where_conditions
      w_string = '1=1 '
      w_values = []

      @fields.each do |name, f|
        val = v(name)

        next if val.nil?

        w_field = f.make_where(val)
        next if w_field.nil?

        w_cond, w_value = w_field

        w_string << " AND #{w_cond} "
        w_values << w_value
      end

      [w_string, *w_values]
    end


    ####

    def method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if @fields.has_key? method_sym
        v(method_sym)
      else
        super
      end
    end

  end

end