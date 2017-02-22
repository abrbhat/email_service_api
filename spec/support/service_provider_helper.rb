RSpec.configure do |config|
  config.before(:each) do
    # Overriding list of service providers to include only mailgun
    allow(ServiceProvider::Base).to receive(:list)
                                .and_return(["Mailgun"])

    # Overriding send email to successfully process emails without calling
    # the third-party api
    class << ServiceProvider::Mailgun
      def send_email(email)
        email.recipients.map{|r| r[:status] = "sent"}
      end
    end
  end
end
