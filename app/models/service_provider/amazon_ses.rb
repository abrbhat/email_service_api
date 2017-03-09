module ServiceProvider
  # AmazonSES API placeholder
  class AmazonSES < ServiceProvider::Base
    def send_email(_email)
      { status: 'error' }
    end
  end
end
