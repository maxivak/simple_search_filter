$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "simple_search_filter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "simple_search_filter"
  s.version     = SimpleSearchFilter::VERSION
  s.authors     = ["Max Ivak"]
  s.email       = ["maxivak@gmail.com"]
  s.homepage    = "https://github.com/maxivak/simple_search_filter"
  s.summary     = "Create search filters. It helps create forms for search filters, sort, paginate data. "
  s.description = "The gem makes it easier to create search filters for your pages. It helps create forms for search filters, sort, paginate data. Search filters are forms used to filters the rows on pages with list/table data."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 6.0.2"

  s.add_development_dependency "mysql2"
end
