require 'bundler/setup'
require 'sinatra'

require './config/config'

get '/' do
  @memes = Meme.order('id DESC').limit(20).all
  haml :index
end

get '/memes' do
  content_type :json
  Meme.order('id DESC').limit(20).all.to_json(:methods => :url)
end

post '/memes' do
  content_type :json
  attrs = JSON.parse request.body.read
  Meme.create!(attrs).to_json(:methods => :url)
end

# Workaround for same-domain security policy with canvas, lol
# TODO: this is a terrible idea
get '/proxyimage' do
  content_type 'image/png'
  open params[:url]
end


class Meme < ActiveRecord::Base
  attr_accessor :base64

  def url
    "/uploads/memes/#{id}.png" if persisted?
  end

  after_save do
    if base64
      base64.sub!('data:image/png;base64,', '')
      image = Base64.decode64 base64
      FileUtils.mkdir_p 'public/uploads/memes'
      File.open("public/uploads/memes/#{id}.png", 'w') {|f| f.write(image)}
    end
  end
end
