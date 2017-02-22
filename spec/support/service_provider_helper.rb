RSpec.shared_context "mock service providers", :service_provider => :mock do
  before(:each) do
    # Overriding list of service providers to include only mandrill
    allow(ServiceProvider::Base).to receive(:list)
                                .and_return(["MandrillAPI"])

    # Overriding send email to successfully process emails without calling
    # the third-party api
    class << ServiceProvider::MandrillAPI
      def send_email(email)
        email.recipients.map{|r| r[:status] = "sent"}
      end
    end
  end
end
