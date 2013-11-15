require 'open3'

class TestAgent < MiniTest::Chef::TestCase
  def test_livestatus_version
    version = node['check_mk']['server']['package']['version']
    socket = node['check_mk']['server']['paths']['livestatus_unix_socket']

    stdin, stdout, stderr = Open3.popen3("unixcat #{socket}")
    stdin.puts "GET status\nColumns: livestatus_version"
    stdin.close

    assert version == stdout.read.chop
  end
end
