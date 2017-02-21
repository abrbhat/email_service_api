module ServiceProvider
  class AmazonSES < ServiceProvider::Base
    def self.send_email(email)
      return {status: "error"}
    end
  end
end
