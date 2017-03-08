module V1
  # Controller for handling emails
  class EmailsController < ApplicationController
    def create
      @email = Email.new(email_params)

      if @email.dispatch
        render_response_ok
      elsif @email.errors.present?
        render_response_errors
      else
        # If email could not be dispatched despite it having no errors, this
        # means the service providers must be unable to send mail
        render_response_service_unavailable
      end
    end

    private

    def render_response_ok
      render(
        json: { status: @email.recipients },
        status: :ok
      )
    end

    def render_response_errors
      render(
        json: { errors: @email.errors },
        status: :unprocessable_entity
      )
    end

    def render_response_service_unavailable
      render(
        json: { errors: ['service_unavailable'] },
        status: :service_unavailable
      )
    end

    def email_params
      return {} if params[:email].blank?

      params.require(:email).permit(
        :subject,
        :body,
        to: [],
        cc: [],
        bcc: [],
        attachments: []
      )
    end
  end
end
