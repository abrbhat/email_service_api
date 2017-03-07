require 'mailgun'

module ServiceProvider
  # Mailgun API declaration
  class MailgunAPI < ServiceProvider::Base
    def self.send_email(email)
      mailgun_client = ::Mailgun::Client.new ENV['MAILGUN_API_KEY']

      # Send your message through the client
      result = mailgun_client.send_message(
        ENV['MAILGUN_SENDER_EMAIL'].split('@')[1],
        construct_mailgun_message(email)
      )

      handle_result(result, email)
    rescue ::Mailgun::Error => error
      Rails.logger.error "mailgun_error: #{error.inspect}"

      { status: 'error', error: error }
    end

    def self.sandbox?
      ENV['MAILGUN_SANDBOX_ACCOUNT'] == 'true'
    end

    def self.handle_result(result, email)
      if result.code == 200
        handle_sent_success(email)

        { status: 'processed' }
      else
        { status: 'error' }
      end
    end

    def self.construct_mailgun_message(email)
      mailgun_message = ::Mailgun::MessageBuilder.new

      mailgun_message.from(ENV['MAILGUN_SENDER_EMAIL'])

      add_recipients(mailgun_message, email)

      mailgun_message.subject(email.subject)

      mailgun_message.body_text(email.body)

      add_attachments(mailgun_message, email)

      mailgun_message
    end

    def self.handle_sent_success(email)
      delivery_statuses =
        if sandbox?
          get_delivery_statuses_for_sandbox(email, delivery_statuses)
        else
          get_delivery_statuses_for_production(email, delivery_statuses)
        end

      email.update_delivery_statuses(delivery_statuses)
    end

    def self.get_delivery_statuses_for_sandbox(email, delivery_statuses)
      delivery_statuses = {}

      present_authorized_recipients(email).each do |authorized_email|
        delivery_statuses[authorized_email] = 'sent'
      end

      delivery_statuses
    end

    def self.get_delivery_statuses_for_production(email)
      delivery_statuses = {}

      email.not_sent_to_recipients.each do |recipient|
        delivery_statuses[recipient[:email_id]] = 'sent'
      end

      delivery_statuses
    end

    def self.add_recipients(mailgun_message, email)
      if sandbox?
        present_authorized_recipients(email).each do |authorized_email|
          mailgun_message.add_recipient(:to, authorized_email)
        end
      else
        add_recipients_if_no_sandbox(email)
      end
    end

    def self.add_recipients_if_no_sandbox(email)
      email.not_sent_to_recipients.each do |recipient|
        mailgun_message.add_recipient(
          recipient[:type].to_sym,
          recipient[:email_id]
        )
      end
    end

    def self.add_attachments(mailgun_message, email)
      email.attachments.each do |attachment|
        mailgun_message.add_attachment(
          attachment.path,
          attachment.original_filename
        )
      end
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
