require 'rubygems'
require 'bundler'
Bundler.require :default, :development
require File.join(File.dirname(__FILE__), "..", "lib", "coin")

class CoinTest < MicroTest::Test

  test "read/write operations" do
    value = rand(999)**rand(100)
    Coin.instance.write(:key1, value, 1)
    assert Coin.instance.read(:key1) == value
  end

  test "expires data properly" do
    value = rand(999)**rand(100)
    Coin.instance.write(:key2, value, 2)
    assert Coin.instance.read(:key2) == value
    sleep(1)
    assert Coin.instance.read(:key2) == value
    sleep(1)
    assert Coin.instance.read(:key2).nil?
    assert !Coin.instance.instance_eval{@dict.has_key?(:key2)}
  end

  test "expires data after 50 reads of any value" do
    Coin.instance.clean_threshold = 50
    value1 = rand(999)**rand(100)
    value2 = rand(999)**rand(100)
    Coin.instance.write(:key3, value1, 1)
    Coin.instance.write(:key3_alt, value2)

    sleep(1)

    # value should exist before a sweep is triggered
    value = Coin.instance.instance_eval { @dict[:key3] }
    assert value[:value] == value1

    # value should not exist after a sweep is triggered
    50.times { Coin.instance.read :key3_alt }
    value = Coin.instance.instance_eval { @dict[:key3] }
    assert value.nil?
  end

end
