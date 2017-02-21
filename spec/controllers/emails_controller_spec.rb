require 'rails_helper'

RSpec.describe EmailsController, type: :controller do

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

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # EmailsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    allow(ServiceProvider::Base).to receive(:list)
                                .and_return(["Mailgun"])

    allow(ServiceProvider::Mailgun).to receive(:send_email)
                                   .and_return({status: "sent"})
  end

  describe "POST #create" do
    context "with valid params" do
      it "dispatches a new Email" do
        expect_any_instance_of(Email).to receive(:dispatch)

        post :send_email,
             params: {email: valid_attributes},
             session: valid_session
      end

      it "replies with 200 status code" do
        post :send_email,
             params: {email: valid_attributes},
             session: valid_session

        expect(response).to have_http_status(:ok)
      end

      it "replies with status as sent_email_successfully" do
        post :send_email,
             params: {email: valid_attributes},
             session: valid_session
        expect(json["status"]).to be_present
        expect(json["status"]).to eq "sent_email_successfully"
      end

      it "replies with the dispatched email" do
        post :send_email,
             params: {email: valid_attributes},
             session: valid_session
        expect(json["email"]).to be_present
        expect(json["email"]["subject"]).to be_present
        expect(json["email"]["subject"]).to eq(valid_attributes[:subject])
      end
    end

    context "with invalid params" do
      it "replies with unprocessable_entity status code" do
        post :send_email,
             params: {email: invalid_attributes},
             session: valid_session

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "replies with status as error" do
        post :send_email,
             params: {email: invalid_attributes},
             session: valid_session
        expect(json["status"]).to be_present
        expect(json["status"]).to eq "error"
      end

      it "replies with errors fields" do
        post :send_email,
             params: {email: invalid_attributes},
             session: valid_session

        expect(json["errors"]).to be_present
      end
    end

    context "no api available" do
      before do
        allow(ServiceProvider::Mailgun).to receive(:send_email)
                                       .and_return({status: "error"})
      end

      it "should return service_unavailable status code" do
        post :send_email,
             params: {email: valid_attributes},
             session: valid_session

        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end
end
