require "rails_helper"

RSpec.describe EmailsController, type: :routing do
  describe "routing" do
    it "routes to #send_email" do
      expect(:post => "/api/emails").to route_to(
        "emails#send_email",
        :format => :json
      )
    end
  end
end
