require 'mandrill'
require 'base64'

module ServiceProvider
  # MandrillAPI service provider
  class MandrillAPI < ServiceProvider::Base
    def send_email(email)
      mandrill = Mandrill::API.new ENV['MANDRILL_API_KEY']

      result = mandrill.messages.send contruct_message(email), false

      delivery_statuses = get_delivery_statuses(result)

      email.update_delivery_statuses(delivery_statuses)

      { status: 'processed' }
    rescue Mandrill::Error => error
      Rails.logger.error "mandrill_error: #{error.inspect}"

      { status: 'error', error: error }
    end

    private

    def get_delivery_statuses(result)
      delivery_statuses = {}

      result.each do |delivery_status|
        delivery_statuses[delivery_status['email']] =
          case delivery_status['status']
          when /sent|queued|rejected/ then delivery_status['status']
          else 'not_sent'
          end
      end

      delivery_statuses
    end

    def get_recipients(email)
      email.not_sent_to_recipients.map do |recipient|
        {
          'type' => recipient[:type],
          'email' => recipient[:email_id]
        }
      end
    end

    def get_attachments(email)
      email.attachments.map do |attachment|
        {
          content: Base64.encode64(IO.binread(attachment.path)),
          name: attachment.original_filename,
          type: attachment.content_type
        }
      end
    end

    def contruct_message(email)
      {
        'subject' => email.subject,
        'html' => email.body,
        'from_email' => ENV['MANDRILL_SENDER_EMAIL'],
        'to' => get_recipients(email),
        'attachments' => get_attachments(email)
      }
    end
  end
end
