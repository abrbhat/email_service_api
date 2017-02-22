require 'mandrill'

module ServiceProvider
  class MandrillAPI < ServiceProvider::Base
    def self.send_email(email)
      begin
        mandrill = Mandrill::API.new ENV['MANDRILL_API_KEY']

        recipients = email.not_sent_to_recipients.map do |recipient|
          {
            "type" => recipient[:type].to_s,
            "email" => recipient[:email_id]
          }
        end

        message = {
          "subject" => email.subject,
          "html" => email.body,
          "from_email" => ENV['SENDER_EMAIL'],
          "to" => recipients
        }

        async = false
        result = mandrill.messages.send message, async
        
        result.sort_by{|delivery_status| delivery_status["email"]}
              .zip(
                email.not_sent_to_recipients
                .sort_by{|recipient| recipient[:email_id]}
              ).each do |delivery_status, recipient|
          if delivery_status["email"] == recipient[:email_id]
            recipient[:status] =
              case delivery_status["status"]
              when /sent|queued|rejected/
                delivery_status["status"]
              end
          end
        end

        return {status: "processed"}
      rescue Mandrill::Error => e
        return {status: "error", error: e}
      end
    end
  end
end
