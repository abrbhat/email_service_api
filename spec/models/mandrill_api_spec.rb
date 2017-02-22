require 'rails_helper'
require 'mandrill'

RSpec.describe ServiceProvider::MandrillAPI, type: :model do
  before do
    @email = Email.new({
      subject: "Hi",
      body: "Hi there",
      to: ["alice@example.com"],
      attachments: []
    })

    class Messages
      def send(*args)
        delivery_statuses = args[0]["to"].map do |recipient|
          {
            "email"=>recipient["email"],
            "status"=>"sent",
            "_id"=>"4e194c8c05b14a6882bb7a52e1caf50d",
            "reject_reason"=>nil
          }
        end

        return delivery_statuses
      end
    end

    allow_any_instance_of(Mandrill::API).to receive(:messages)
                                        .and_return(Messages.new)
  end

  context "mandrill executes request successfully" do
    before do
      class Messages
        def send(*args)
          delivery_statuses = args[0]["to"].map do |recipient|
            {
              "email"=>recipient["email"],
              "status"=>"sent",
              "_id"=>"4e194c8c05b14a6882bb7a52e1caf50d",
              "reject_reason"=>nil
            }
          end

          return delivery_statuses
        end
      end

      allow_any_instance_of(Mandrill::API).to receive(:messages)
                                          .and_return(Messages.new)

    end

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
      class Messages
        def send(*args)
          raise Mandrill::Error.new
        end
      end

      allow_any_instance_of(Mandrill::API).to receive(:messages)
                                          .and_return(Messages.new)

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
