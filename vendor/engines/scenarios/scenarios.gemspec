$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "scenarios/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "scenarios"
  s.version     = Scenarios::VERSION
  s.authors     = ["Nicolas Meylan"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "Scenarios plugin for RORganize applications."
  s.description = "Scenarios is a little plugin that may help you to create Issues by writing scenarios/story of use cases."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
#  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"
  # s.add_dependency "jquery-rails"
end
