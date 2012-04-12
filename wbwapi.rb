# Making the ruby files in ./lib accessible
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'lib'))

require 'sinatra'
require 'json'
require 'wbw/client'

enable :sessions

before do
  content_type :json
  @wbw_client = Wbw::Client.new(session[:wbw])
end

after do
  session[:wbw] = @wbw_client.to_hash if @wbw_client
end

get '/login' do
  http_try { {}.to_json if @wbw_client.login(params[:username], params[:password]) }
end

get '/logout' do
  http_try { {}.to_json if @wbw_client.logout }
end

get '/lists' do
  http_try { @wbw_client.lists.to_json }
end

get '/payments/:lid' do
  http_try { @wbw_client.payments(params[:lid]).to_json } 
end

def http_try
  yield
rescue Wbw::Exceptions::HTTPException => e
  [e.response_code, {error_message: e.message}.to_json]
end
