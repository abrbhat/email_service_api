module ServiceProvider
  # AmazonSES API placeholder
  class AmazonSES < ServiceProvider::Base
    def self.send_email(_email)
      { status: 'error' }
    end
  end
end
