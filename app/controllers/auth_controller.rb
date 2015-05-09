module AuthController
  def self.registered(app)

    app.helpers do
      def authorized?
        !!session[:token]
      end

      def require_authorization
        redirect to('/login') unless authorized?
      end
    end

    app.get '/login' do
      @auth_url = github.authorize_url
      haml :login
    end

    app.get '/logout' do
      session.delete(:token)
      redirect to('/')
    end

    app.get '/callback' do
      token = github.get_token(params[:code])
      session[:token] = token.token
      redirect to('/')
    end

  end
end
