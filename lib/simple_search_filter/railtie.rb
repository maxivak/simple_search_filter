require 'rails/railtie'

module SimpleSearchFilter
  class Railtie < Rails::Railtie
    #config.eager_load_namespaces << SimpleSearchFilter

    if Rails.env.development?
      config.watchable_dirs['lib'] = [:rb]
      config.watchable_dirs['lib/simple_search_filter'] = [:rb]
      config.watchable_dirs['app/views'] = [:rb]
    end


    initializer 'simple_search_filter' do |_app|
      # init my gem
    end

    config.after_initialize do

    end
  end
end

