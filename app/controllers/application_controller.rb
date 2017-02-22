class ApplicationController < ActionController::API
  before_action :check_if_api_key_is_valid

  protected

  def check_if_api_key_is_valid
    account = Account.where(api_key: params[:api_key]).first

    if params[:api_key].blank?
      render json: {
               errors: ["no_api_key_present"]
             },
             status: :unauthorized
      return
    elsif account.blank?
      render json: {
               errors: ["invalid_api_key"]
             },
             status: :unauthorized
      return
    end
  end
end
