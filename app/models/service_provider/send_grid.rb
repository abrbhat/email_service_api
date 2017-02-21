module ServiceProvider
  class SendGrid < ServiceProvider::Base
    def self.send(email)
      return {status: "sent_mail"}
    end
  end
end
