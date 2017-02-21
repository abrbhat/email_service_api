module ServiceProvider
  class Base
    @@list = [
      'AmazonSES',
      'Mailgun',
      'SendGrid',
      'Mandrill'
    ]

    def self.list
      @@list
    end
  end
end
