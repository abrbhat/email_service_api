require 'rails_helper'

RSpec.describe ServiceProvider::MandrillAPI, type: :model do
  before do
    @email = Email.new({
      subject: "Hi",
      body: "Hi there",
      to: ["alice@example.com"],
      attachments: []
    })
  end

  context "mandrill executes request successfully" do
    it "should update email status" do
      ServiceProvider::MandrillAPI.send_email(@email)

      expect(@email.recipients[0][:status]).to eq("sent")
    end

    it "should return status processed" do
      response = ServiceProvider::MandrillAPI.send_email(@email)

      expect(response[:status]).to eq("processed")
    end
  end

  context "mandrill executes request unsuccessfully" do
    before do
      class MandrillMessages
        def send(*args)
          raise Mandrill::Error.new
        end
      end
    end

    it "should not update email status" do
      ServiceProvider::MandrillAPI.send_email(@email)

      expect(@email.recipients[0][:status]).to eq("not_sent")
    end

    it "should return status error" do
      response = ServiceProvider::MandrillAPI.send_email(@email)

      expect(response[:status]).to eq("error")
    end
  end
end
