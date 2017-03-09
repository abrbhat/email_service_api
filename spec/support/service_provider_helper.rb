RSpec.configure do |config|
  config.before(:each) do
    module ServiceProvider
      # Mock base class for service provider
      class Base
        # Use only MandrillAPI for tests
        def self.list
          [
            'MandrillAPI'
          ]
        end
      end
    end
  end
end
