RSpec.configure do |config|
  config.before(:each) do
    # Use only MandrillAPI for test
    allow(ServiceProvider::Base).to receive(:list)
      .and_return(['MandrillAPI'])
  end
end
