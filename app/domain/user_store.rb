class UserStore < GithubStore
  memoize def self.find(username)
    github.users.get(user: username)
  end
end
