require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'compass'
require 'sass/plugin/rack'
require 'barista'
require 'jammit-sinatra'
require 'padrino-helpers'
require 'active_record'
require 'open-uri'
require 'base64'

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
    if @base64
      base64.sub!('data:image/png;base64,', '')
      image = Base64.decode64 base64
      File.open("public/uploads/memes/#{id}.png", 'w') {|f| f.write(image)}
    end
  end
end
