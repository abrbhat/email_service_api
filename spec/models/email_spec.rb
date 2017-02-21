require 'rails_helper'

RSpec.describe Email, type: :model do
  describe "initialization" do
    it "assign the parameters to the object attributes" do
      email_parameters = {
        subject: "Hi there",
        body: "How are you?",
        to: ["alice@example.com"],
        cc: ["bob@example.com"],
        bcc: ["trudy@example.com"]
      }

      email = Email.new(email_parameters)

      expect(email.subject).to eq(email_parameters[:subject])
      expect(email.body).to eq(email_parameters[:body])
      expect(email.to).to eq(email_parameters[:to])
      expect(email.cc).to eq(email_parameters[:cc])
      expect(email.bcc).to eq(email_parameters[:bcc])
    end

    it "initializes subject and body to an empty string if none present" do
      email = Email.new()

      expect(email.subject).to eq("")
      expect(email.body).to eq("")
    end

    it "initializes to, cc and bcc to arrays if not already arrays" do
      email = Email.new({
        to: "alice@example.com",
        cc: ["bob@example.com"]
      })

      expect(email.to).to eq(["alice@example.com"])
      expect(email.cc).to eq(["bob@example.com"])
      expect(email.bcc).to eq([])
    end
  end

  describe "dispatch" do
    let(:valid_parameters){
      {
        subject: "Hi Alice",
        body: "Just saying hi.",
        to: ["alice@example.com"]
      }
    }

    context "invalid email" do
      it "should return false" do
        email = Email.new()

        expect(email.dispatch).to eq false
      end
    end

    context "valid email" do
      before do
        allow(ServiceProvider::Base).to receive(:list)
                                    .and_return(["Mailgun"])
      end

      it "should call service provider" do
        expect(ServiceProvider::Mailgun).to receive(:send)

        Email.new(valid_parameters).dispatch
      end

      it "should return true if service provider is returns a success response" do
        expect(ServiceProvider::Mailgun).to receive(:send)
                                        .and_return({status: 'sent_mail'})

        expect(Email.new(valid_parameters).dispatch).to eq true
      end

      it "should return false if service provider does not return a success" +
         " response" do
        expect(ServiceProvider::Mailgun).to receive(:send)
                                        .and_return({status: 'error'})

        expect(Email.new(valid_parameters).dispatch).to eq false
      end
    end
  end

  describe "is_valid?" do
    it "returns false if no recipients are present" do
      email = Email.new()

      expect(email.send(:is_valid?)).to eq false
    end

    it "should add error to email if no recipients are present" do
      email = Email.new()

      email.send(:is_valid?)

      expect(email.errors.count).to eq 1
      expect(email.errors.to_a[0]).to eq "no_recipient_present"
    end

    it "returns false if any recipient has invalid email id" do
      email = Email.new({
        to: "abcdef"
      })

      expect(email.send(:is_valid?)).to eq false
    end

    it "should add error to email if any recipient has invalid email id" do
      email = Email.new({
        to: "abcdef"
      })

      email.send(:is_valid?)

      expect(email.errors.count).to eq 1
      expect(email.errors.to_a[0]).to eq "invalid_emails:abcdef"
    end

    it "returns true if email is valid" do
      email = Email.new({
        to: "alice@example.com"
      })

      expect(email.send(:is_valid?)).to eq true
    end
  end
end
