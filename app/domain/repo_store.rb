class RepoStore < GithubStore
  memoize def self.find(user, repo)
    github.repos.get(user, repo)
  end

  def self.find_by_query(input)
    match = input.match(/#{input['github.com/']}(?<user>[^\/]+)\/(?<repo>[^\/]+)/)
    raise ArgumentError unless match
    self.find(match[:user], match[:repo])
  end

  def self.pull_requests_for(repository, limit: 20, options: {state: 'closed', sort: 'updated'})
    pull_requests = github.pulls.list(repository.owner.login, repository.name, options)
    pull_requests.first(limit).each do |pull_request|
      pull_request.user = UserStore.find(pull_request.user.login)
    end
  end
end
