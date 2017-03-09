require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'Emails', type: :request do
  let(:json) { JSON.parse(response.body) }

  let(:valid_attributes) do
    {
      subject: 'How are you?',
      body: 'Hi, Just wanted to know how are you. Regards.',
      to: ['alice@example.com'],
      cc: ['bob@example.com'],
      bcc: ['trudy@example.com']
    }
  end

  let(:invalid_attributes) do
    {
      subject: 'How are you?',
      body: 'Hi, Just wanted to know how are you. Regards.'
    }
  end

  describe 'POST /api/emails' do
    context 'no api key' do
      it 'should return response with a status code of 401' do
        post v1_emails_path,
             params: {
               email: valid_attributes
             }

        expect(response).to have_http_status(401)
      end

      it 'should return response with error that no api key is present' do
        post v1_emails_path,
             params: {
               email: valid_attributes
             }

        expect(json['errors']).to be_present
        expect(json['errors'][0]).to eq 'no_api_key_present'
      end
    end

    context 'invalid api key' do
      it 'should return response with a status code of 401' do
        post v1_emails_path,
             params: {
               email: valid_attributes,
               api_key: 'any_string'
             }

        expect(response).to have_http_status(401)
      end

      it 'should return response with error that api key is invalid' do
        post v1_emails_path,
             params: {
               email: valid_attributes,
               api_key: 'any_string'
             }

        expect(json['errors']).to be_present
        expect(json['errors'][0]).to eq 'invalid_api_key'
      end
    end

    context 'valid api key' do
      before do
        @api_key = Account.create(api_key: 'test_api_key').api_key
      end
      context 'service is available' do
        context 'valid params' do
          before do
            allow_any_instance_of(Mandrill::API).to receive(:messages)
              .and_return(@mock_mandrill_message_success)
          end

          it 'should return response with a status code of 200' do
            post v1_emails_path,
                 params: {
                   email: valid_attributes,
                   api_key: @api_key
                 }

            expect(response).to have_http_status(200)
          end

          it 'should return status of emails' do
            post v1_emails_path,
                 params: {
                   email: valid_attributes,
                   api_key: @api_key
                 }

            recipient_emails = valid_attributes[:to] +
                               valid_attributes[:cc] +
                               valid_attributes[:bcc]

            expect(json['status'].length).to eq(3)
            expect(json['status'].map { |r| r['email_id'] } -
              recipient_emails).to eq([])
            expect(json['status'].map { |r| r['status'] }.uniq).to eq(['sent'])
          end
        end

        context 'invalid params' do
          it 'should return response with a status code of 422' do
            post v1_emails_path,
                 params: {
                   email: invalid_attributes,
                   api_key: @api_key
                 }

            expect(response).to have_http_status(422)
          end

          it 'should return errors in email' do
            post v1_emails_path,
                 params: {
                   email: invalid_attributes,
                   api_key: @api_key
                 }

            expect(json['errors']).to be_present
          end
        end
      end
      context 'service is unavailable' do
        before do
          allow_any_instance_of(Mandrill::API).to receive(:messages)
            .and_raise(Mandrill::Error)
        end

        it 'should return response with a status code of 503' do
          post v1_emails_path,
               params: {
                 email: valid_attributes,
                 api_key: @api_key
               }

          expect(response).to have_http_status(503)
        end
      end
    end
  end
end
