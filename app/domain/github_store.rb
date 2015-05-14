class GithubStore
  extend Memoizer

  def self.github(options={})
    options[:oauth_token] ||= @@token if defined?(@@token)
    Github.new(API_PARAMS.merge(options))
  end

  def self.authenticate!(token)
    @@token = token
  end
end
