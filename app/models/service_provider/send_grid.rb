module ServiceProvider
  # Placeholder for SendGrid API integration
  class SendGrid < ServiceProvider::Base
    def self.send_email(_email)
      { status: 'error' }
    end
  end
end
