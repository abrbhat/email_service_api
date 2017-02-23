RSpec.configure do |config|
  config.before(:each) do
    class Mailgun::Client
      def send_message_successful(*args)
        return OpenStruct.new ({
          "code" => 200
        })
      end

      alias_method :send_message, :send_message_successful
    end
  end
end

RSpec.shared_context "mailgun send unsuccessful" do
  before(:each) do
    class Mailgun::Client
      def send_message_unsuccessful(*args)
        return OpenStruct.new ({
          "code" => 503
        })
      end

      alias_method :send_message, :send_message_unsuccessful
    end
  end
end

RSpec.shared_context "mailgun send error" do
  before(:each) do
    class Mailgun::Client
      def send_message_error(*args)
        raise Mailgun::Error.new
      end

      alias_method :send_message, :send_message_error
    end
  end
end
