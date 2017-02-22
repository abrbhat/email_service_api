class EmailsController < ApplicationController
  def send_email
    @email = Email.new(email_params)
    
    if @email.dispatch
      render json: {
               status: @email.recipients
             },
             status: :ok
    elsif @email.errors.present?
      render json: {
                errors: @email.errors
             },
             status: :unprocessable_entity
    else
      render json: {
                errors: ["service_unavailable"]
             },
             status: :service_unavailable
    end
  end

  private

  def email_params
    return {} if params[:email].blank?

    params.require(:email).permit(
      :subject,
      :body,
      :to => [],
      :cc => [],
      :bcc => [],
      :attachments => []
    )
  end
end
