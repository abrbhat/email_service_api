require 'rails_helper'

RSpec.describe "Emails", type: :request do
  include_context "mock service providers"
  
  let(:json){ JSON.parse(response.body) }

  let(:valid_attributes) {
    {
      subject: "How are you?",
      body: "Hi, Just wanted to know how are you. Regards.",
      to: ["alice@example.com"],
      cc: ["bob@example.com"],
      bcc: ["trudy@example.com"]
    }
  }

  let(:invalid_attributes) {
    {
      subject: "How are you?",
      body: "Hi, Just wanted to know how are you. Regards."
    }
  }

  describe "POST /api/emails" do
    context "service is available" do
      context "valid params" do
        it "should return response with a status code of 200" do
          post emails_path,
               params: {:email => valid_attributes}

          expect(response).to have_http_status(200)
        end

        it "should return status of emails" do
          post emails_path,
               params: {:email => valid_attributes}

          recipient_emails = valid_attributes[:to] +
                             valid_attributes[:cc] +
                             valid_attributes[:bcc]

          expect(json["status"].length).to eq(3)
          expect(json["status"].map{|r| r["email_id"]} - recipient_emails).to eq([])
          expect(json["status"].map{|r| r["status"]}.uniq).to eq(["sent"])
        end
      end

      context "invalid params" do
        it "should return response with a status code of 422" do
          post emails_path,
               params: {:email => invalid_attributes}

          expect(response).to have_http_status(422)
        end

        it "should return errors in email" do
          post emails_path,
               params: {:email => invalid_attributes}

          expect(json["errors"]).to be_present
        end
      end
    end
    context "service is unavailable" do
      before do
        # Overriding send email to unsuccessfully process emails without calling
        # the third-party api
        class << ServiceProvider::MandrillAPI
          def send_email(email)
            email.recipients.map{|r| r[:status] = "not_sent"}
          end
        end
      end

      it "should return response with a status code of 503" do
        post emails_path,
             params: {:email => valid_attributes}

        expect(response).to have_http_status(503)
      end
    end
  end
end
