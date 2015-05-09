require 'rubygems'
require 'bundler'
Bundler.require(:default)
require_relative 'controllers/auth_controller'

API_PARAMS = {
  client_id: ENV['GITHUB_CLIENT_ID'],
  client_secret: ENV['GITHUB_CLIENT_SECRET']
}

class MainApp < Sinatra::Base
  register AuthController

  enable :sessions

  helpers do
    def github(options={})
      options[:oauth_token] ||= session[:token] if authorized?
      @_github ||= Github.new(API_PARAMS.merge(options))
    end

    def parse_github_link(link)
      match = link.to_s.match(/github\.com\/(?<user>[^\/]+)\/(?<repo>[^\/]+)/)
      raise ArgumentError unless match[:user] && match[:repo]
      [match[:user], match[:repo]]
    end

    def top_contributors_for(repository, limit: 5)
      contributors = github.repos.contributors(repository.owner.login, repository.name)
      contributors.first(limit).map{|contributor| github.users.get(user: contributor.login)}
    end

    def pull_requests_for(repository, limit: 20)
      filter = { state: 'closed', sort: 'updated' }
      pull_requests = github.pulls.list(repository.owner.login, repository.name, filter)
      pull_requests.first(limit).each do |pull_request|
        pull_request.user = github.users.get(user: pull_request.user.login)
      end
    end
  end

  get '/' do
    require_authorization
    haml :index
  end

  # TO INCLUDE: Organizations, Hirable
  get '/search' do
    require_authorization
    user, repo = parse_github_link(params[:q])
    @repository = github.repos.get(user, repo)
    @top_contributors = top_contributors_for @repository
    @pull_requests = pull_requests_for @repository
    haml :show
  end

  run! if app_file == $0
end
