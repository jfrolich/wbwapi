# Making the ruby files in ./lib accessible
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'lib'))

require 'sinatra'
require 'json'
require 'wbw/client'

enable :sessions

before do |b|
  content_type :json
  @wbw_client = Wbw::Client.new(session[:wbw])
end

after do
  session[:wbw] = @wbw_client.to_hash if @wbw_client
end

get '/login' do
  begin
    @wbw_client.login(params[:username], params[:password])
    {}.to_json
  rescue Wbw::Exceptions::Exception => e
    return_error e
  end
end

get '/logout' do
  @wbw_client.logout
  {}.to_json
end

get '/lists' do
  begin
    @wbw_client.lists.to_json
  rescue Wbw::Exceptions::Exception => e
    return_error e
  end
end

get '/payments/:lid' do
  begin
    @wbw_client.payments(params[:lid]).to_json
  rescue Wbw::Exceptions::Exception => e
    return_error e
  end
end

def return_error e
  [e.response_code, {error_message: e.message}.to_json]
end
