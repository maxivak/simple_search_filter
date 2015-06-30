require 'simple_search_filter/filter_field'
require 'simple_search_filter/filter_data'

module SimpleSearchFilter
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
      if formtype.to_s==FilterField::FORM_TYPE_AUTOCOMPLETE
        add_field_autocomplete(name, type, formtype, opt)
      else
        add_field FilterField.new(name,type, formtype, opt)
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

    def add_field_autocomplete(name, type, formtype, opt={})
      search_by = opt[:search_by] || :text

      if search_by==:id
        # filter by id

        # id field
        opt_id = opt.clone
        opt_id[:default_value] = 0
        opt_id[:ignore_value] = 0
        opt_id[:condition] = FilterField::QUERY_CONDITION_EQUAL

        id_name = field_name_for_id_autocomplete(name).to_sym
        add_field FilterField.new(id_name, FilterField::TYPE_INT, FilterField::FORM_TYPE_EMPTY, opt_id)

        # text field
        opt_text = opt.clone
        opt_text[:default_value] = ''
        opt_text[:ignore_value] = ''
        opt_text[:condition] = FilterField::QUERY_CONDITION_EMPTY

        add_field FilterField.new(name,type, formtype, opt_text)

      else
        # filter by text
        add_field FilterField.new(name,type, formtype, opt)
      end

    end


    def field_name_for_id_autocomplete(name)
      "#{name}_id"
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
      options[:page_param_name] || SimpleSearchFilter.page_default_param_name
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
      data_sess = session_get 'data', nil
      unless data_sess.nil?
        if data_sess.is_a?(FilterData)
          @data = data_sess
        elsif data_sess.is_a?(Hash)
          @data = FilterData.new
          @data.set_values(data_sess)
        else
          #y=0
        end
      end

      #
      @data ||= FilterData.new

      data_save_to_session

      #
      @data
    end

    def data_save_to_session
      session_save('data', @data.values)
    end

    def v(name, v_def=nil)
      name = name.to_s

      res = data.v(name, field_def_value(name))
      return res unless res.nil?

      v_def
    end


    def v_empty?(name)
      data.v_empty?(name)
    end

    def set(field_name,v)
      field = @fields[field_name]
      vv = field.nil? ? v : field.fix_value(v)

      data.set(field_name, vv)
    end


    def clear_all
      self.page=1
      clear_order
      clear_data
    end

    def clear_data
      data.clear

      session_save 'data', @data
    end

    def set_data_from_form(params)
      # search for fields like filter[XXX]
      params.each do |k, v|
        name = k.to_sym

        #if f =~ /^filter\[([^\]]+)\]$/
        #name = Regexp.last_match(1)

        next unless @fields.has_key? name

        t = @fields[name].type
        if t==FilterField::TYPE_INT
          set name, (v.to_i rescue 0)
        elsif t==FilterField::TYPE_BOOLEAN
          set name, FilterField.fix_value_boolean(v)
        else
          set name, v
        end

        #end
      end

      # default values from fields
      @fields.each do |k, f|
        name = k.to_s
        next if data.v_exist? name

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
      @order_default = [[order_by, order_dir]]

      #
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

    def clear_order
      self.order = @order_default
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


  end

end