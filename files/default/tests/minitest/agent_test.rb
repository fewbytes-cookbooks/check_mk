class TestAgent < MiniTest::Chef::TestCase
  def test_agent_listen
    assert TCPSocket.new('localhost', node['check_mk']['agent']['port'])
  end
end