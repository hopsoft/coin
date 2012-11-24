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
  spec.description   = "A simple in memory cache."
  spec.summary       = "Coin is a simple in memory cache."
  spec.homepage      = ""

  spec.files = FileList[
    'lib/**/*.rb',
    'test/**/*.rb',
    'Gemfile',
    'Gemfile.lock',
    'LICENSE.txt',
    'README.md'
  ].to_a
end
