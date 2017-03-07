require "rails_helper"

RSpec.describe V1::EmailsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/api/v1/emails").to route_to(
        "v1/emails#create",
        :format => :json
      )
    end
  end
end
