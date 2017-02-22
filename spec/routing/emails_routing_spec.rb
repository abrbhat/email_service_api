require "rails_helper"

RSpec.describe V1::EmailsController, type: :routing do
  describe "routing" do
    it "routes to #send_email" do
      expect(:post => "/api/v1/emails").to route_to(
        "v1/emails#send_email",
        :format => :json
      )
    end
  end
end
