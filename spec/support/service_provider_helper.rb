RSpec.configure do |config|
  config.before(:each) do
    class ServiceProvider::Base
      # Use only MandrillAPI for tests
      def self.list
        return [
          "MandrillAPI"
        ]
      end
    end
  end
end
