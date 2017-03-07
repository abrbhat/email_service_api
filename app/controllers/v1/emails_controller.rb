class V1::EmailsController < ApplicationController
  def create
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
      # If email could not be dispatched despite it having no errors, this means
      # the service providers must be unable to send mail
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
