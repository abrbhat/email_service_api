class EmailsController < ApplicationController
  def send_email
    @email = Email.new(email_params)

    if @email.dispatch
      render json: {
               status: "sent_email_successfully",
               email: @email,
               errors: []
             },
             status: :ok
    elsif @email.errors.present?
      render json: {
                status: "error",
                errors: @email.errors
             },
             status: :unprocessable_entity
    else
      render json: {
                status: "error",
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
      :bcc => []
    )
  end
end
