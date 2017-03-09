require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe ServiceProvider::MandrillAPI, type: :model do
  let(:mock_mandrill_client) { double(Mandrill::API) }

  before do
    @mandrill_api = ServiceProvider::MandrillAPI.new

    @mandrill_api.client = mock_mandrill_client

    @email = Email.new(
      subject: 'Hi',
      body: 'Hi there',
      to: ['alice@example.com']
    )
  end

  context 'mandrill executes request successfully' do
    before do
      allow(mock_mandrill_client).to receive(:messages)
        .and_return(@mock_mandrill_message_success)
    end

    it 'should update email status' do
      @mandrill_api.send_email(@email)

      expect(@email.recipients[0][:status]).to eq('sent')
    end

    it 'should return status processed' do
      response = @mandrill_api.send_email(@email)

      expect(response[:status]).to eq('processed')
    end
  end

  context 'mandrill executes request with error' do
    before do
      allow(mock_mandrill_client).to receive(:messages)
        .and_raise(Mandrill::Error)
    end

    it 'should not update email status' do
      @mandrill_api.send_email(@email)

      expect(@email.recipients[0][:status]).to eq('not_sent')
    end

    it 'should return status error' do
      response = @mandrill_api.send_email(@email)

      expect(response[:status]).to eq('error')
    end
  end
end
