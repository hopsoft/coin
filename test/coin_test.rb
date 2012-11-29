require File.join(File.dirname(__FILE__), "test_helper")

class CoinTest < MicroTest::Test

  after do
    Coin.stop_server
  end

  test "start_server" do
    Coin.start_server
    assert Coin.server_running?
  end

  test "stop_server" do
    Coin.start_server
    assert Coin.server_running?
    Coin.stop_server
    assert Coin.server_running? == false
  end

  test "server method starts the server" do
    Coin.stop_server
    Coin.server
    assert Coin.server_running?
  end

end
