require 'socket'

class TestAgent < MiniTest::Chef::TestCase
  def test_agent_listen

    count = 0
    begin
      TCPSocket.new('localhost', node['check_mk']['agent']['port'])
    rescue Errno::ECONNREFUSED => e
      if count < 3
        count += 1; sleep 1; retry
      else
        raise e
      end
    end

  end
end