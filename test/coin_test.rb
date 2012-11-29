require File.join(File.dirname(__FILE__), "test_helper")

class CoinTest < MicroTest::Test
  before do
    @key = "key-#{SecureRandom.uuid}"
  end

  after do
    Coin.stop_server
  end

  test "stop_server" do
    Coin.start_server
    assert Coin.server_running?
    Coin.stop_server
    assert Coin.server_running? == false
  end

  test "server method starts the server" do
    Coin.stop_server
    assert !Coin.server_running?
    Coin.server
    assert Coin.server_running?
  end

  test "read access starts the server" do
    Coin.stop_server
    assert !Coin.server_running?
    Coin.read :foo
    assert Coin.server_running?
  end

  test "read with assignment block" do
    value = rand(99999999999)
    assert Coin.read(@key).nil?
    Coin.read(@key) { value }
    sleep 0.5
    assert Coin.read(@key) == value
  end

end
