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
    def github(options={})
      @_github ||= Github.new(API_PARAMS.merge(options))
    end

    def require_authorization
      redirect to('/login') unless !!session[:token]
    end

    def parse_github_link(link)
      link_re = /github\.com\/(?<user>[^\/]+)\/(?<repo>[^\/]+)/
      match = link.to_s.match(/github\.com\/(?<user>[^\/]+)\/(?<repo>[^\/]+)/)
      raise ArgumentError unless match[:user] && match[:repo]
      [match[:user], match[:repo]]
    end
  end

  get '/' do
    require_authorization
    haml :index
  end

  get '/search' do
    require_authorization
    user, repo = parse_github_link(params[:q])
    @repository = github(oauth_token: session[:token]).repos.get(user, repo)
    @contributors = github.repos.contributors(user, repo).map do |contributor|
      github.users.get user: contributor.login
    end
    haml :show
  end

  get '/login' do
    @auth_url = github.authorize_url
    haml :login
  end

  get '/logout' do
    session.delete(:token)
    redirect to('/')
  end

  get '/callback' do
    token = github.get_token(params[:code])
    session[:token] = token.token
    redirect to('/')
  end

  run! if app_file == $0
end
