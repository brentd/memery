require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'open-uri'
require 'base64'

get '/' do
  haml :index
end

post '/' do
  if base64 = params[:base64]
    base64.sub!('data:image/png;base64,', '')
    image = Base64.decode64 base64
    File.open('image.png', 'w') {|f| f.write(image)}
  end
end

get '/getimage' do
  content_type 'image/png'
  open params[:url]
end
