require 'mandrill'
require 'base64'

module ServiceProvider
  class MandrillAPI < ServiceProvider::Base
    def self.send_email(email)
      begin
        mandrill = Mandrill::API.new ENV['MANDRILL_API_KEY']

        recipients = email.not_sent_to_recipients.map do |recipient|
          {
            "type" => recipient[:type],
            "email" => recipient[:email_id]
          }
        end

        attachments = email.attachments.map do |attachment|
          {
            content: Base64.encode64(IO.binread(attachment.path)),
            name: attachment.original_filename,
            type: attachment.content_type
          }
        end

        message = {
          "subject" => email.subject,
          "html" => email.body,
          "from_email" => ENV['MANDRILL_SENDER_EMAIL'],
          "to" => recipients,
          "attachments" => attachments
        }

        async = false
        result = mandrill.messages.send message, async

        delivery_statuses = {}

        result.each do |delivery_status|
          delivery_statuses[delivery_status["email"]] =
            case delivery_status["status"]
            when /sent|queued|rejected/
              delivery_status["status"]
            else
              "not_sent"
            end
        end

        email.update_delivery_statuses(delivery_statuses)

        {status: "processed"}
      rescue Mandrill::Error => error
        Rails.logger.error "mandrill_error: #{error.inspect}"

        {status: "error", error: error}
      end
    end
  end
end
