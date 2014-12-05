require "rubygems"
require "pry-test"
require "coveralls"

Coveralls.wear!
SimpleCov.command_name "pry-test"

require File.expand_path("../../lib/coin", __FILE__)
