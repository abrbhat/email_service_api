class WelcomeController < ActionController::API
  def index
    render json: {
      message: "Hi, head over to https://github.com/abrbhat/email_service_api" \
               " to learn more about the api"
    }
  end
end
