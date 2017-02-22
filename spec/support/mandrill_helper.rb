RSpec.configure do |config|
  config.before(:each) do
    class MandrillMessages
      def successful_send(*args)
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

      def unsuccessful_send(*args)
        delivery_statuses = args[0]["to"].map do |recipient|
          {
            "email"=>recipient["email"],
            "status"=>"not_sent",
            "_id"=>"4e194c8c05b14a6882bb7a52e1caf50d",
            "reject_reason"=>nil
          }
        end

        return delivery_statuses
      end

      def error_send(*args)
        raise Mandrill::Error.new
      end

      alias_method :send, :successful_send
    end

    class Mandrill::API
      def messages
        return MandrillMessages.new
      end
    end
  end
end
