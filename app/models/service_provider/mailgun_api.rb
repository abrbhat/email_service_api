require 'mailgun'

module ServiceProvider
  class MailgunAPI < ServiceProvider::Base
    def self.send_email(email)
      begin
        mg_client = ::Mailgun::Client.new ENV['MAILGUN_API_KEY']
        mb_obj = ::Mailgun::MessageBuilder.new()

        mb_obj.from(ENV['MAILGUN_SENDER_EMAIL'])

        if ENV['MAILGUN_SANDBOX_ACCOUNT'] == "true"
          # Allows multiple authorized email separated by |
          # Example: "test1@example.com|test2@example.com"
          ENV['MAILGUN_AUTHORIZED_EMAIL'].split("|").each do |authorized_email|
            mb_obj.add_recipient(:to, authorized_email)
          end
        else
          email.not_sent_to_recipients.each do |recipient|
            mb_obj.add_recipient(recipient[:type].to_sym, recipient[:email_id])
          end
        end

        mb_obj.subject(email.subject);

        mb_obj.body_text(email.body);

        email.attachments.each do |attachment|
          mb_obj.add_attachment attachment.path, attachment.original_filename
        end

        # Send your message through the client
        result = mg_client.send_message ENV['MAILGUN_SENDER_EMAIL'].split('@')[1],
                                        mb_obj

        if result.code == 200
          delivery_statuses = {}

          if ENV['MAILGUN_SANDBOX_ACCOUNT'] == "true"
            ENV['MAILGUN_AUTHORIZED_EMAIL'].split("|").each do |authorized_email|
              delivery_statuses[authorized_email] = "sent"
            end
          else
            email.not_sent_to_recipients.each do |recipient|
              delivery_statuses[recipient[:email_id]] = "sent"
            end
          end

          email.update_delivery_statuses(delivery_statuses)

          return {status: "processed"}
        else
          return {status: "error"}
        end

      rescue ::Mailgun::Error => error
        Rails.logger.error "mailgun_error: #{error.inspect}"

        return {status: "error", error: error}
      end
    end
  end
end
