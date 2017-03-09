RSpec.configure do |config|
  config.before(:each) do
    allow(ServiceProvider::Base).to receive(:list)
      .and_return(['MandrillAPI'])
  end
end
