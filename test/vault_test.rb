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

  test "read_and_delete" do
    value = rand(999999999)
    @vault.write(@key, value)
    val = @vault.read_and_delete(@key)
    assert @vault.read(@key).nil?
    assert val == value
  end

  test "delete" do
    @vault.write(@key, true)
    assert @vault.read(@key)
    @vault.delete(@key)
    assert @vault.read(@key).nil?
  end

  test "clear" do
    10.times { |i| @vault.write("key#{i}", true) }
    assert @vault.length >= 10
    @vault.clear
    assert @vault.length == 0
  end

end
