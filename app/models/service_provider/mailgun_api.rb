require 'mailgun'

module ServiceProvider
  class MailgunAPI < ServiceProvider::Base
    def self.send_email(email)
      begin
        mg_client = ::Mailgun::Client.new ENV['MAILGUN_API_KEY']
        mb_obj = ::Mailgun::MessageBuilder.new()

        mb_obj.from(ENV['MAILGUN_SENDER_EMAIL'])

        # Allows multiple authorized email separated by |
        # Example: "test1@example.com|test2@example.com"
        ENV['MAILGUN_AUTHORIZED_EMAIL'].split("|").each do |authorized_email|
          mb_obj.add_recipient(:to, authorized_email)
        end

        mb_obj.subject("#{email.subject} (mailgun)");

        mb_obj.body_text(email.body);

        email.attachments.each do |attachment|
          mb_obj.add_attachment attachment.path, attachment.original_filename
        end

        # Send your message through the client
        result = mg_client.send_message ENV['MAILGUN_SENDER_EMAIL'].split('@')[1],
                                        mb_obj

        if result.code == 200
          email.update_delivery_statuses({
            ENV['MAILGUN_AUTHORIZED_EMAIL'] => "sent"
          })

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
