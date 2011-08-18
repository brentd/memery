require './app'
require 'barista'
require 'sinatra/activerecord/rake'

namespace :assets do

  desc "Packages all assets with Jammit (SASS, CoffeeScript, etc)"
  task :compile do
    puts "Compiling SASS/Compass..."
    Sass::Plugin.force_update_stylesheets

    puts "\nCompiling Coffeescripts..."
    Barista.compile_all!

    puts "\nPackaging Jammit..."
    Jammit.package!

    puts "DONE!"
  end

end
