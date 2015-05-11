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

  helpers do
    def parse_github_link(link)
      match = link.to_s.match(/github\.com\/(?<user>[^\/]+)\/(?<repo>[^\/]+)/)
      raise ArgumentError unless match[:user] && match[:repo]
      [match[:user], match[:repo]]
    end

    def top_contributors_for(repository, limit: 5)
      contributors = GithubStore.github.repos.contributors(repository.owner.login, repository.name)
      contributors.first(limit).map{|contributor| UserStore.find(contributor.login)}
    end

    def pull_requests_for(repository, limit: 20)
      filter = { state: 'closed', sort: 'updated' }
      pull_requests = GithubStore.github.pulls.list(repository.owner.login, repository.name, filter)
      pull_requests.first(limit).each do |pull_request|
        pull_request.user = UserStore.find(pull_request.user.login)
      end
    end
  end

  before do
    GithubStore.authenticate! session[:token]
  end

  get '/' do
    require_authorization
    haml :index
  end

  # TO INCLUDE: Organizations, Hirable
  get '/search' do
    require_authorization
    @repository = RepoStore.find *parse_github_link(params[:q])
    @top_contributors = top_contributors_for @repository
    @pull_requests = pull_requests_for @repository
    haml :show
  end

  run! if app_file == $0
end
