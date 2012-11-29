require File.join(File.dirname(__FILE__), "test_helper")
require "securerandom"

class VaultTest < MicroTest::Test

  before do
    @vault = Coin::Vault.instance
    @key = "key-#{SecureRandom.uuid}"
  end

  test "read using an unstored key" do
    assert @vault.read(@key).nil?
  end

  test "basic write & read" do
    value = rand(999999999)
    @vault.write(@key, value)
    assert @vault.read(@key) == value
  end

end
