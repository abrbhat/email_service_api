require 'mailgun'

module ServiceProvider
  # Mailgun API declaration
  class MailgunAPI < ServiceProvider::Base
    def self.send_email(email)
      mailgun_client = ::Mailgun::Client.new ENV['MAILGUN_API_KEY']
      mailgun_message = ::Mailgun::MessageBuilder.new

      mailgun_message.from(ENV['MAILGUN_SENDER_EMAIL'])

      if ENV['MAILGUN_SANDBOX_ACCOUNT'] == 'true'
        present_authorized_recipients(email).each do |authorized_email|
          mailgun_message.add_recipient(:to, authorized_email)
        end
      else
        email.not_sent_to_recipients.each do |recipient|
          mailgun_message.add_recipient(
            recipient[:type].to_sym,
            recipient[:email_id]
          )
        end
      end

      mailgun_message.subject(email.subject)

      mailgun_message.body_text(email.body)

      email.attachments.each do |attachment|
        mailgun_message.add_attachment(
          attachment.path,
          attachment.original_filename
        )
      end

      # Send your message through the client
      result = mailgun_client.send_message(
        ENV['MAILGUN_SENDER_EMAIL'].split('@')[1],
        mailgun_message
      )

      if result.code == 200
        handle_sent_success(email)

        { status: 'processed' }
      else
        { status: 'error' }
      end
    rescue ::Mailgun::Error => error
      Rails.logger.error "mailgun_error: #{error.inspect}"

      { status: 'error', error: error }
    end

    def self.sandbox?
      ENV['MAILGUN_SANDBOX_ACCOUNT'] == 'true'
    end

    def self.handle_sent_success(email)
      delivery_statuses = {}

      if sandbox?
        present_authorized_recipients(email).each do |authorized_email|
          delivery_statuses[authorized_email] = 'sent'
        end
      else
        email.not_sent_to_recipients.each do |recipient|
          delivery_statuses[recipient[:email_id]] = 'sent'
        end
      end

      email.update_delivery_statuses(delivery_statuses)
    end

    def self.authorized_recipients
      # Allows multiple authorized email separated by |
      # Example: "test1@example.com|test2@example.com"
      ENV['MAILGUN_AUTHORIZED_EMAIL'].split('|')
    end

    def self.present_authorized_recipients(email)
      (authorized_recipients &
       email.not_sent_to_recipients.map { |e| e[:email_id] })
    end
  end
end
