require 'minitest/autorun'
require 'wbw/client'

USER_AGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'

module Wbw
  class ClientTest < MiniTest::Unit::TestCase
    def setup
    end
    
    def test_login
      wbw_client = Wbw::Client.new('jaap@dynamicka.com','jaapook')
      assert_equal wbw_client.login, true
      
      #wbw_client.password = 'jaapook2'
      #assert_equal wbw_client.login, false 

    end
  end
end
