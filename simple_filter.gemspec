$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "simple_filter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "simple_filter"
  s.version     = SimpleFilter::VERSION
  s.authors     = ["Max Ivak"]
  s.email       = ["maxivak@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SimpleFilter."
  s.description = "TODO: Description of SimpleFilter."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "sqlite3"
end
