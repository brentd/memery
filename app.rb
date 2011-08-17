require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'compass'
require 'sass/plugin/rack'
require 'barista'
require 'jammit-sinatra'
require 'padrino-helpers'
require 'open-uri'
require 'base64'

configure do
  Sinatra.register Padrino::Helpers

  # Compass
  Compass.configuration.tap do |c|
    c.sass_dir = 'app/stylesheets'
    c.css_dir  = 'public/compiled/css'
  end
  Compass.configure_sass_plugin!
  use Sass::Plugin::Rack

  # Barista
  Barista.configure do |c|
    c.root        = File.join settings.root, 'app', 'coffeescripts'
    c.output_root = File.join settings.root, 'public', 'compiled', 'js'
  end
  use Barista::Filter

  # Jammit
  Jammit.load_configuration(File.join settings.root, 'config', 'assets.yml')
  Sinatra.register Jammit
end

set :views, 'app/views'

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


#get '/css/:name.css' do
  #content_type 'text/css', :charset => 'utf-8'
  #sass(:"app/stylesheets/#{params[:name]}", Compass.sass_engine_options)
#end
