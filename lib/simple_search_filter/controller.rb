require 'active_support/concern'

module SimpleSearchFilter
  module Controller
    extend ActiveSupport::Concern

    included do

    end

    def init_search_data(name)
      # input
      pg = params[@filter.page_param_name].to_i || 1
      cmd = params[:cmd] || ''

      # page
      @filter.page = pg

      # input from GET
      @filter.fields.each do |name, f|
        if params.has_key? name
          @filter.set name, params[name]
        end
      end

      # post - save filter and redirect
      #if request.post? && params[:filter]
      if params[:filter]
        if cmd=='clear'
          @filter.clear_data
        else
          @filter.set_data_from_form params[:filter]
        end

        #(redirect_to url and return) if @filter.search_method_post_and_redirect?
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