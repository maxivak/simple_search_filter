module SimpleFilter
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


# load simple_filter components
require 'simple_filter/filter'


module SimpleFilter
  extend ActiveSupport::Autoload

  #autoload :Helpers

#  eager_autoload do
#    autoload :Components
#    autoload :ErrorNotification
#  end


  # configuration
end



# extend model
require 'simple_filter/searchable'


# extend controller, helpers
require 'simple_filter/controller'
require 'simple_filter/helpers'
require 'simple_filter/simple_form_extensions/wrappers_bootstrap'


class ActionController::Base
  include SimpleFilter::Controller

  helper SimpleFilter::Helpers
end

#ActionController::Base.send(:helper, SimpleFilter::Helpers)



ActiveSupport.on_load(:action_view) do
  #include SemanticId::Helper
  #helper SimpleFilter::Helpers
end


if defined? Rails
  require 'simple_filter/railtie'
  require 'simple_filter/engine'
end
