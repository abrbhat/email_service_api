class EmailController < ApplicationController
  def send_email
    email = Email.new(email_params)
    
    if email.dispatch
      render json: {
               status: "sent_email_successfully",
               errors: []
             },
             status: :ok
    else
      render json: {
                status: "error",
                errors: email.errors
             },
             status: :unprocessable_entity
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
      :bcc => []
    )
  end
end
