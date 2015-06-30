require 'active_support/concern'

module SimpleSearchFilter
  module Controller
    extend ActiveSupport::Concern

    included do

    end

    def init_search_data(name)
      # input
      pg = params[@filter.page_param_name]
      cmd = params[:filter_cmd] || ''

      # page
      unless pg.nil?
        pg = (pg.to_i rescue 1)
        @filter.page = pg
      end


      #
      if cmd=='apply' || cmd=='set' || cmd=='clear'
        @filter.clear_all
      end

      # input from GET
      @filter.fields.each do |name, f|
        if params.has_key? name
          @filter.set name, params[name]
        end
      end


      # input from form
      # post - save filter and redirect
      #if request.post? && params[:filter]
      if params[:filter]
        @filter.set_data_from_form params[:filter]
        @filter.data_save_to_session
        #(redirect_to url and return) if @filter.search_method_post_and_redirect?
      else
        # clean url => set page to 1
        if @filter.search_method_post_and_redirect? && request.get? && cmd=='' && pg.nil?
          @filter.page=1
        elsif cmd=='back'
          # do not touch filter - load it from session
        end

      end

      if cmd=='order'
        @filter.set_order params[:orderby], params[:orderdir]
        (redirect_to action: name.to_sym and return) if @filter.search_method_post_and_redirect?
      end

    end

    module ClassMethods
      def search_filter(name, options = {}, &block)
        # raise "You need a block to build!" unless block_given?

        init_method = "init_search_filter_#{name.to_s}"

        define_method(init_method) do
          prefix = options[:prefix] || "filter_#{params[:controller]}_#{name}"

          # create Filter object
          @filter = SimpleSearchFilter::Filter.new(self.session, prefix, options)

          # define filter
          @filter.instance_eval(&block)

          # set data from params
          init_search_data(name)

        end

        # before_action callback
        self.before_action :"#{init_method}", only: [name.to_sym, options[:search_action]]


        #
        define_method("#{options[:search_action]}") do
          redirect_to action: name.to_sym
        end
      end

    end
  end
end
