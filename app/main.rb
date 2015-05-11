require 'rubygems'
require 'bundler'
Bundler.require(:default)

$LOAD_PATH.unshift File.expand_path('..', File.dirname(__FILE__))
require 'lib/memoizer'
require 'app/controllers/auth_controller'
require 'app/domain/github_store'
require 'app/domain/repo_store'
require 'app/domain/user_store'

API_PARAMS = {
  client_id: ENV['GITHUB_CLIENT_ID'],
  client_secret: ENV['GITHUB_CLIENT_SECRET']
}

class MainApp < Sinatra::Base
  register AuthController
  enable :sessions
  set :show_exceptions, false

  before do
    GithubStore.authenticate! session[:token]
  end

  error do
    session[:error] = {
      class: env['sinatra.error'].class.name,
      message: env['sinatra.error'].message
    }
    redirect to('/')
  end

  get '/' do
    require_authorization
    haml :index
  end

  # TO INCLUDE: Organizations, Hirable
  get '/search' do
    require_authorization
    @repository = RepoStore.find_by_query params[:q].to_s
    @top_contributors = UserStore.contributors_for @repository
    @pull_requests = RepoStore.pull_requests_for @repository
    haml :show
  end

  run! if app_file == $0
end
