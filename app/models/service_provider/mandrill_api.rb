require 'mandrill'

module ServiceProvider
  class MandrillAPI < ServiceProvider::Base
    def self.send_email(email)
      begin
        mandrill = Mandrill::API.new ENV['MANDRILL_API_KEY']

        to_fields = []

        [:to, :cc, :bcc].each do |field|
          email.send(field).each do |receiver_email|
            to_fields << {"type" => field.to_s, "email" => receiver_email}
          end
        end

        message = {
          "subject" => email.subject,
          "html" => email.body,
          "from_email" => ENV['SENDER_EMAIL'],
          "to" => to_fields
        }

        async = false
        result = mandrill.messages.send message, async

        if result[0]["status"] == "sent"
          return {status: "sent"}
        else
          return {status: "error", error: result[0]["reject_reason"]}
        end
      rescue Mandrill::Error => e
        return {status: "error", error: e}
      end
    end
  end
end
