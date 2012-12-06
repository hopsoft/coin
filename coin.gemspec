# -*- encoding: utf-8 -*-
require "rake"
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coin/version'

Gem::Specification.new do |spec|
  spec.name          = "coin"
  spec.version       = Coin::VERSION
  spec.authors       = ["Nathan Hopkins"]
  spec.email         = ["natehop@gmail.com"]
  spec.summary       = "An absurdly simple in memory object caching system."
  spec.description   = ""
  spec.homepage      = "https://github.com/hopsoft/coin"
  spec.license       = "MIT"

  spec.files = FileList[
    'lib/**/*.rb',
    'test/**/*.rb',
    'bin/*',
    'Gemfile',
    'Gemfile.lock',
    'LICENSE.txt',
    'README.md'
  ].to_a
end
