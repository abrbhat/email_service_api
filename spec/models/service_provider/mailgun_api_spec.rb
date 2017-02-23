require 'rails_helper'

RSpec.describe ServiceProvider::MailgunAPI, type: :model do
  before do
    ENV["MAILGUN_AUTHORIZED_EMAIL"] = "test@example.com"

    @email = Email.new({
      subject: "Hi",
      body: "Hi there",
      to: ["test@example.com"]
    })
  end

  context "mailgun executes request successfully" do
    it "should update email status" do
      ServiceProvider::MailgunAPI.send_email(@email)

      expect(@email.recipients[0][:status]).to eq("sent")
    end

    it "should return status processed" do
      response = ServiceProvider::MailgunAPI.send_email(@email)

      expect(response[:status]).to eq("processed")
    end
  end

  context "mailgun executes request unsuccessfully" do
    include_context "mailgun send unsuccessful"

    it "should not update email status" do
      ServiceProvider::MailgunAPI.send_email(@email)

      expect(@email.recipients[0][:status]).to eq("not_sent")
    end

    it "should return status error" do
      response = ServiceProvider::MailgunAPI.send_email(@email)

      expect(response[:status]).to eq("error")
    end
  end

  context "mailgun executes request unsuccessfully" do
    include_context "mailgun send error"

    it "should not update email status" do
      ServiceProvider::MailgunAPI.send_email(@email)

      expect(@email.recipients[0][:status]).to eq("not_sent")
    end

    it "should return status error" do
      response = ServiceProvider::MailgunAPI.send_email(@email)

      expect(response[:status]).to eq("error")
    end
  end
end