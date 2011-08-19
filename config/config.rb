require 'haml'
require 'compass'
require 'sass/plugin/rack'
require 'barista'
require 'jammit-sinatra'
require 'padrino-helpers'
require 'active_record'
require 'open-uri'
require 'base64'


configure do
  set :views, 'app/views'
  set :database, 'db/db.sqlite3'

  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: settings.database)
  ActiveRecord::Base.include_root_in_json = false

  Sinatra.register Padrino::Helpers

  # Compass
  Compass.configuration.tap do |c|
    c.sass_dir = 'app/stylesheets'
    c.css_dir  = 'public/css/compiled'
  end
  Compass.configure_sass_plugin!
  use Sass::Plugin::Rack

  # Barista
  Barista.configure do |c|
    c.root        = File.join settings.root, 'app', 'coffeescripts'
    c.output_root = File.join settings.root, 'public', 'js', 'compiled'
  end
  use Barista::Filter

  # Jammit
  Jammit.load_configuration(File.join settings.root, 'config', 'assets.yml')
  helpers Jammit::Helper
end
