module ServiceProvider
  class AmazonSES < ServiceProvider::Base
    def self.send(email)
      return {status: "sent_mail"}
    end
  end
end
