require 'rubygems'
require 'bundler'
Bundler.require :default, :development
require File.join(File.dirname(__FILE__), "..", "lib", "coin")

class CoinTest < MicroTest::Test

  test "read/write operations" do
    Coin.instance.write(:some_key, 754839, 1)
    assert Coin.instance.read(:some_key) == 754839
  end

  test "expires data properly" do
    Coin.instance.write(:some_key, 5372962379, 2)
    assert Coin.instance.read(:some_key) == 5372962379
    sleep(1)
    assert Coin.instance.read(:some_key) == 5372962379
    sleep(1)
    assert Coin.instance.read(:some_key).nil?
    assert !Coin.instance.instance_eval{@dict.has_key?(:some_key)}
  end

  test "expires data after 50 reads of any value" do
    Coin.instance.write(:some_key, 8903478, 1)
    Coin.instance.write(:some_other_key, true, 5)
    assert Coin.instance.read(:some_key) == 8903478
    sleep(1)
    50.times {Coin.instance.read :some_other_key}
    assert Coin.instance.read(:some_key).nil?
    assert !Coin.instance.instance_eval{@dict.has_key?(:some_key)}
  end

end
