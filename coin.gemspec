# -*- encoding: utf-8 -*-
require File.expand_path("../lib/coin/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "coin"
  gem.license       = "MIT"
  gem.version       = Coin::VERSION
  gem.authors       = ["Nathan Hopkins"]
  gem.email         = ["natehop@gmail.com"]
  gem.summary       = "An absurdly simple in memory object caching system."
  gem.description   = "An absurdly simple in memory object caching system."
  gem.homepage      = "https://github.com/hopsoft/coin"

  gem.files = Dir["lib/**/*.rb", "bin/*", "[A-Z].*"]
  gem.test_files = Dir["test/**/*.rb"]
  gem.executables = "coin"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-test"
  gem.add_development_dependency "coveralls"
  #gem.add_development_dependency "pry-stack_explorer"
  #gem.add_development_dependency "pry-rescue"
end
