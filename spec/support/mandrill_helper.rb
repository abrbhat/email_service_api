RSpec.configure do |config|
  config.before(:all) do
    @mock_mandrill_message_success =
      (
        Struct.new('Message') do
          def send(*args)
            delivery_statuses = args[0]['to'].map do |recipient|
              {
                'email' => recipient['email'],
                'status' => 'sent',
                '_id' => '4e194c8c05b14a6882bb7a52e1caf50d',
                'reject_reason' => nil
              }
            end

            delivery_statuses
          end
        end
      ).new
  end
end
