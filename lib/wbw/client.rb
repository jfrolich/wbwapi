require 'net/http'
require 'nokogiri'

module Wbw
  class Client
    attr_accessor :logged_in, :username

    def login username, password
      params = parameterize action: 'login', username: username, password: password
      @username = username

      resp, data = http.post("/index.php", params, headers)

      # because the server does not send back correct HTTP codes we
      # check if the response body includes "Uitloggen"
      @logged_in = !!(/Uitloggen/m.match resp.body)
    end

    def lists
      if html = fetch("/index.php?page=dashboard")
        doc = Nokogiri.HTML(html)
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

    def list_content lid
      if html = fetch("index.php?page=balance&lid=#{lid}&sort_column=timestamp&rows=10000")
        doc = Nokogiri.HTML(html)
        list_content = doc.css("#list tbody tr")
      end
    end

    def logout
      html = fetch("/index.php?action=logout")
      !@logged_in = !(/Uitgelogd/m.match html)
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
        return nil
        @logged_in = false
      end
      html
    end
  end
end
