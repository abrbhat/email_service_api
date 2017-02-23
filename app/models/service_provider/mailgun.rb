module ServiceProvider
  require 'mailgun'

  class Mailgun < ServiceProvider::Base
    def self.send_email(email)
        begin
          mg_client = ::Mailgun::Client.new ENV['MAILGUN_API_KEY']
          mb_obj = ::Mailgun::MessageBuilder.new()

          mb_obj.from(ENV['MAILGUN_SENDER_EMAIL'])

          mb_obj.add_recipient(:to, "bhatnagarabhiroop@gmail.com")

          mb_obj.subject("#{email.subject} (mailgun)");

          mb_obj.body_text(email.body);

          email.attachments.each do |attachment|

          end

          # Send your message through the client
          result = mg_client.send_message ENV['MAILGUN_SENDER_EMAIL'].split('@')[1],
                                          mb_obj

          if result.code == 200
            email.update_delivery_statuses({
              "bhatnagarabhiroop@gmail.com" => "sent"
            })
          end
        rescue ::Mailgun::Error => e
          return {status: "error", error: e}
        end
    end
  end
end
