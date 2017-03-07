# Service provider module
module ServiceProvider
  # Base class for service provider
  class Base
    @list = %w(
      AmazonSES
      MailgunAPI
      SendGrid
      MandrillAPI
    )

    class << self
      attr_reader :list
    end
  end
end
