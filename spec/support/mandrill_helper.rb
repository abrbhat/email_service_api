RSpec.configure do |config|
  config.before(:each) do
    class MandrillMessages
      def send(*args)
        delivery_statuses = args[0]["to"].map do |recipient|
          {
            "email"=>recipient["email"],
            "status"=>"sent",
            "_id"=>"4e194c8c05b14a6882bb7a52e1caf50d",
            "reject_reason"=>nil
          }
        end

        return delivery_statuses
      end
    end

    class Mandrill::API
      def messages
        return MandrillMessages.new
      end
    end
  end
end
