class RepoStore < GithubStore
  memoize def self.find(user, repo)
    github.repos.get(user, repo)
  end
end
