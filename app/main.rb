require 'rubygems'
require 'bundler'
Bundler.require(:default)

API_PARAMS = {
  client_id: ENV['GITHUB_CLIENT_ID'],
  client_secret: ENV['GITHUB_CLIENT_SECRET']
}

class MainApp < Sinatra::Base
  enable :sessions

  helpers do
    def require_authorization
      redirect to('/login') unless !!session[:token]
    end
  end

  get '/' do
    require_authorization
    haml :index
  end

  get '/search' do
    require_authorization
    @query = params[:q]
    github = Github.new(API_PARAMS.merge oauth_token: session[:token])
    haml :show
  end

  get '/login' do
    @auth_url = Github.new(API_PARAMS).authorize_url
    haml :login
  end

  get '/logout' do
    session.delete(:token)
    redirect to('/')
  end

  get '/callback' do
    token = Github.new(API_PARAMS).get_token(params[:code])
    session[:token] = token.token
    redirect to('/')
  end

  run! if app_file == $0
end
