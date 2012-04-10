# Add the libary directory to the LOAD_PATH
# this makes running the test as easy as just running script
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..','..','lib'))

require 'minitest/autorun'
require 'wbw/client'
require 'pry'

module Wbw
  class ClientTest < MiniTest::Unit::TestCase
    def setup
    end

    def login u='jaap@dynamicka.com', p='testtest', f=false
      @wbw_client ||= Wbw::Client.new
      @wbw_client.login(u,p) if !@wbw_client.logged_in || f
    end

    def test_login
      login
      assert_equal true, @wbw_client.logged_in
      assert_operator @wbw_client.session_id.length, :>, 1
    end

    def test_faulty_login
      assert_raises Wbw::Exceptions::Unauthorized do
        login 'bademail@email.com', 'test', true
      end

      assert_equal false, @wbw_client.logged_in
    end

    def test_availability_of_lists
      login
      lists = @wbw_client.lists
      assert_operator lists.count, :>, 0
    end

    def test_availability_of_lists_when_not_logged_in
      login
      @wbw_client.logout
      assert_raises Wbw::Exceptions::Unauthorized do
        lists = @wbw_client.lists
      end
    end

    def test_validness_of_lid
      login
      lists = @wbw_client.lists
      lists.each do |list|
        assert_equal Fixnum, list[:lid].class
        assert_operator list[:lid], :>, 1
      end
    end

    def test_logout
      login
      assert_equal true, @wbw_client.logout
      assert_equal false, @wbw_client.logged_in
    end

    def test_payments
      login
      payments = @wbw_client.payments 97165
      assert_operator payments.count, :>, 0
    end

    def test_payment_types
      login
      payments = @wbw_client.payments 97165
      payments.each do |payment|
        assert_equal String, payment[:by].class
        assert_equal String, payment[:description].class
        assert_equal Float, payment[:amount].class
        assert_equal String, payment[:date].class
        assert_equal String, payment[:participants].class
      end
    end

    def test_serialization
      wbw_client_hash = {cookie: 'PHPSESSID=123jaap;', username: 'jaap@dynamicka.com', logged_in: true}
      wbw_client = Wbw::Client.new wbw_client_hash

      assert_equal '123jaap', wbw_client.session_id
      assert_equal wbw_client_hash[:username], wbw_client.username

      assert_equal wbw_client_hash, wbw_client.to_hash
    end
  end
end
