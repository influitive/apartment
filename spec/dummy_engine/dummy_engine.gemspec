$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dummy_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dummy_engine"
  s.version     = DummyEngine::VERSION
  s.authors     = ["Your name"]
  s.email       = ["Your email"]
  s.homepage    = ""
  s.summary     = "Summary of DummyEngine."
  s.description = "Description of DummyEngine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.6"
  s.add_dependency "apartment"

  s.add_development_dependency "sqlite3"
end
