require 'net/http'
require 'nokogiri'

module Wbw
  class Client
    attr_accessor :username, :password, :logged_in
    
    def initialize u=nil, p=nil
      @username = u
      @password = p
    end

    def parameterize(params)
      URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
    end

    def headers
       {'Cookie' => cookie }
    end

    def cookie
      if @cookie
        @cookie
      else
        # GET request -> so the host can set his cookies
        resp, data = http.get('/index.php')
        @cookie = resp.response['set-cookie']
      end
    end

    def http
      @http || @http = Net::HTTP.new('www.wiebetaaltwat.nl')
    end

    def login
      params = parameterize action: 'login', username: username, password: password

      resp, data = http.post("/index.php", params, headers)

      # because the server does not send back correct HTTP codes we
      # check if the response body includes "Uitloggen"
      logged_in = (resp.body =~ /Uitloggen/m) != nil
    end

    def lists
      params = parameterize page: 'dashboard'
      resp, data = http.get("/index.php?page=dashboard", headers)

      doc = Nokogiri.HTML(resp.body)
      lists = doc.css(".view-lists tbody tr")

      lists.map do |list|
        lid = /lid=(?<lid>[[:digit:]]*)/.match(list.css('a').first['href'])[:lid]
        {
          lid: lid.to_i,
          balance: list.css(".balance-pos").first.content[2..-1]
        }
      end
    end
  end
end
