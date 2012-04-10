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
  @wbw_client.logout if @wbw_client.logged_in
  if @wbw_client.login(params[:username], params[:password])
    {}.to_json
  else
    401
  end
end

get '/lists' do
  if lists = @wbw_client.lists
    lists.to_json
  else
    401
  end
end

get '/payments/:lid' do
  if payments = @wbw_client.payments(params[:lid])
    payments.to_json
  else
    401
  end
end
