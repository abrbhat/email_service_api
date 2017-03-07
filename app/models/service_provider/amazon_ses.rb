module ServiceProvider
  class AmazonSES < ServiceProvider::Base
    def self.send_email(email)
      {status: "error"}
    end
  end
end
