module ServiceProvider
  class Mailgun < ServiceProvider::Base
    def self.send_email(email)
      return {status: "error"}
    end
  end
end
