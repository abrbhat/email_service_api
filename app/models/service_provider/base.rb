module ServiceProvider
  class Base
    @@list = [
      'AmazonSES',
      'Mailgun',
      'SendGrid',
      'MandrillAPI'
    ]

    def self.list
      @@list
    end
  end
end
