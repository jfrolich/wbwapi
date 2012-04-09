require 'minitest/autorun'
require 'wbw/client'
require 'pry'

module Wbw
  class ClientTest < MiniTest::Unit::TestCase
    def setup
    end

    def login u='jaap@dynamicka.com', p='jaapook', f=false
      @wbw_client ||= Wbw::Client.new
      @wbw_client.login(u,p) if !@wbw_client.logged_in || f
    end

    def test_login
      login
      assert_equal true, @wbw_client.logged_in
    end

    def test_faulty_login
      login 'bademail@email.com', 'test', true
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

      lists = @wbw_client.lists
    end

    def test_validness_of_lid
      login
      lists = @wbw_client.lists
      assert_equal lists.first[:lid].class, Fixnum
      assert_operator lists.first[:lid], :>, 1
    end

    def test_logout
      login
      assert_equal true, @wbw_client.logout
      assert_equal false, @wbw_client.logged_in
    end
  end
end
