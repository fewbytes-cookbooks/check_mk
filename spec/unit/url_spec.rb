require 'spec_helper'

describe "GET 'index'" do
	it "returns http success" do
		result = Net::HTTP.get(URI.parse('http://mathias-kettner.de/download/'))
      result.should match("check_mk-1.2.2p3.tar.gz") 
      result.should match("check_mk-agent-1.2.2p3-1.noarch.rpm")
      result.should match("check-mk-agent_1.2.2p3-2_all.deb")
	end
end
