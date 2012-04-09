require 'net/http'

module Wbw
  class Client
    attr_accessor :username, :password
    
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

      # POST request -> logging in
      data = parameterize action: 'login', username: username, password: password
      puts data
      #data = "action=login&username=#{username}&password=#{password}"
      resp, data = http.post("/index.php", data, headers)

      # because the server does not send back correct HTTP codes we
      # check if the response body includes "Uitloggen"
      (resp.body =~ /Uitloggen/m) != nil
    end
  end
end
