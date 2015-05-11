class UserStore < GithubStore
  memoize def self.find(username, options={})
    user = github.users.get(user: username)
    if options[:include_organizations]
      user.singleton_class.send(:attr_accessor, :organizations)
      user.organizations = github.orgs.list(user: user.login)
    end
    user
  end

  def self.contributors_for(repository, limit: 5)
    contributors = github.repos.contributors(repository.owner.login, repository.name)
    contributors.first(limit).map do |contributor|
      self.find(contributor.login, include_organizations: true)
    end
  end
end
