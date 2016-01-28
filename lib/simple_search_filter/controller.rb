require 'active_support/concern'

module SimpleSearchFilter
  module Controller
    extend ActiveSupport::Concern

    included do

    end

    def init_search_data(name)
      # input
      pg = params[@filter.page_param_name]
      cmd = params[Filter::CMD_PARAM_NAME] || ''

      # page
      unless pg.nil?
        pg = (pg.to_i rescue 1)
        @filter.page = pg
      end


      #
      if cmd=='apply' || cmd=='set' || cmd=='clear'
        @filter.clear_all
      end

      # collect input
      if cmd!='clear'
        # input from GET
        @filter.fields.each do |name, f|
          if params.has_key? name
            @filter.set name, params[name]
          end
        end

        # input from form
        # post - save filter and redirect
        #if request.post? && params[:filter]
        if params[:filter] && cmd!='clear'
          @filter.set_data_from_form params[:filter]
          #(redirect_to url and return) if @filter.search_method_post_and_redirect?
        else
          # clean url => set page to 1
          if @filter.search_method_post_and_redirect? && request.get? && cmd=='' && pg.nil?
            @filter.page=1
          elsif cmd=='back'
            # do not touch filter - load it from session
          end

        end

        @filter.data_save_to_session

      end


      #
      if cmd=='order'
        @filter.set_order params[:orderby], params[:orderdir]
        #(redirect_to action: name.to_sym and return) if @filter.search_method_post_and_redirect?
        if @filter.search_method_post_and_redirect?
          u = url_search_filter(@filter)
          raise 'Bad url' if u.nil?
          redirect_to u

          #redirect_to main_app.send(@filter.options[:url])
          #redirect_to send(@filter.options[:url])
        end
      end

    end

    def url_search_filter(filter)
      opt_url = filter.options[:url]
      u = nil
      u = send(opt_url) if u.nil? && respond_to?(opt_url)
      u = main_app.send(opt_url) if u.nil? && main_app.respond_to?(opt_url)

      u
    end

    module ClassMethods
      def search_filter(name, options = {}, &block)
        # raise "You need a block to build!" unless block_given?

        init_method = "init_search_filter_#{name.to_s}"
        search_action_name = (options[:search_action] || 'search')

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
        self.before_action :"#{init_method}", only: [name.to_sym, search_action_name]


        #
        define_method("#{search_action_name}") do
          u = url_search_filter(@filter)
          raise 'Bad url' if u.nil?
          redirect_to u

          #redirect_to action: name.to_sym
          #redirect_to main_app.send(options[:url])
          #redirect_to send(options[:url])
          #redirect_to '/'
        end
      end

    end
  end
end
