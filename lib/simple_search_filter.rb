module SimpleSearchFilter
  mattr_accessor :page_default_param_name

  def page_default_param_name
    (@@page_default_param_name || :page).to_sym
  end

end


# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  #do nothing
end


# load simple_search_filter components
require 'simple_search_filter/filter'


module SimpleSearchFilter
  extend ActiveSupport::Autoload

  #autoload :Helpers

#  eager_autoload do
#    autoload :Components
#    autoload :ErrorNotification
#  end


  # configuration
end



# extend model
require 'simple_search_filter/searchable'


# extend controller, helpers
require 'simple_search_filter/controller'
require 'simple_search_filter/helpers'
require 'simple_search_filter/simple_form_extensions/wrappers_bootstrap'


class ActionController::Base
  include SimpleSearchFilter::Controller

  helper SimpleSearchFilter::Helpers
end

#ActionController::Base.send(:helper, SimpleSearchFilter::Helpers)



ActiveSupport.on_load(:action_view) do
  #include SimpleSearchFilter::Helpers
  #helper SimpleSearchFilter::Helpers
end


if defined? Rails
  require 'simple_search_filter/railtie'
  require 'simple_search_filter/engine'
end
