require 'rubygems'
require 'bundler'
Bundler.require(:default)

class MainApp < Sinatra::Base
  get '/' do
    haml :index
  end

  get '/search' do
  end

  run! if app_file == $0
end
