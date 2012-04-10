require 'net/http'
require 'nokogiri'
require 'wbw/exceptions'

module Wbw
  class Client
    attr_accessor :username, :session_id, :logged_in

    def initialize params = {}
      if params
        @username  = params[:username]
        @cookie    = params[:cookie]
        @logged_in = params[:logged_in]
      end
    end

    def to_hash
      {
        username:  @username,
        cookie:    @cookie,
        logged_in: @logged_in
      }
    end

    def session_id
      if @cookie && match = /PHPSESSID=(?<session_id>[0-9a-z]+);/.match(@cookie)
        match[:session_id]
      end
    end

    def login username, password
      logout if logged_in
      params = parameterize action: 'login', username: username, password: password
 
      self.username = username
      resp = http.post("/index.php", params, headers)

      # because the server does not send back correct HTTP codes we
      # check if the response body includes "Uitloggen"
      if (/Uitloggen/m.match resp.body)
        @logged_in = true
      else
        @logged_in = false
        raise Wbw::Exceptions::Unauthorized if !@logged_in
      end
    end

    def lists
      if doc = fetch("/index.php?page=dashboard")
        lists = doc.css(".view-lists tbody tr")

        lists.map do |list|
          entry = {}
          entry[:lid]     = /lid=(?<lid>[[:digit:]]+)/.match(list.at_css('a')['href'])[:lid].to_i
          entry[:title]   = list.css('a').first.content
          entry[:balance] = list.at_css('.balance-pos').content[2..-1].to_f
          entry
        end
      end
    end

    def payments lid
      if doc = fetch("/index.php?page=balance&lid=#{lid.to_s}&sort_column=timestamp&rows=10000")
        payments = doc.css("#list tbody tr")
        payments.map do |payment|
          entry = {}
          entry[:by]           = payment.at_css('.payment-by').content
          entry[:description]  = payment.at_css('.description').content
          entry[:amount]       = payment.at_css('.amount').content[2..-1].to_f
          entry[:date]         = payment.at_css('.date').content
          entry[:participants] = payment.at_css('.participants').content
          entry
        end
      end
    end

    def logout
      doc = fetch("/index.php?action=logout")
      @cookie = nil
      @logged_in = false
      true
    end

    private

    def parameterize(params)
      URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
    end

    def headers
       {'Cookie' => cookie }
    end

    def cookie
      @cookie = @cookie || http.get('/index.php').response['set-cookie']
    end

    def http
      @http || @http = Net::HTTP.new('www.wiebetaaltwat.nl')
    end

    def fetch url
      html = http.get(url,headers).body
      if /Je hebt geen toegang/.match html
        @logged_in = false
        raise Wbw::Exceptions::Unauthorized
      else
        Nokogiri.HTML html
      end
    end
  end
end
