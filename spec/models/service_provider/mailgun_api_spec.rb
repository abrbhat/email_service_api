require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe ServiceProvider::MailgunAPI, type: :model do
  let(:mock_mailgun_client) { double(Mailgun::Client) }
  let(:mock_mailgun_message_builder) do
    double(
      Mailgun::MessageBuilder,
      from: nil,
      add_recipient: nil,
      subject: nil,
      body_text: nil
    )
  end
  let(:mock_success_result) { OpenStruct.new(code: 200) }
  let(:mock_failure_result) { OpenStruct.new(code: 503) }

  before do
    ENV['MAILGUN_AUTHORIZED_EMAIL'] = 'recipient1@example.com'
    ENV['MAILGUN_SENDER_EMAIL'] = 'sender@example.com'

    @mailgun_api = ServiceProvider::MailgunAPI.new

    @mailgun_api.client = mock_mailgun_client

    allow(@mailgun_api).to receive(:build_mailgun_message)
      .and_return(mock_mailgun_message_builder)

    @email = Email.new(
      subject: 'Hi',
      body: 'Hi there',
      to: ['recipient1@example.com']
    )
  end

  context 'mailgun executes request successfully' do
    before do
      allow(mock_mailgun_client).to receive(:send_message)
        .and_return(mock_success_result)
    end

    describe 'mailgun_message_builder' do
      after do
        @mailgun_api.send_email(@email)
      end

      it 'should call mailgun_message_builder.from with sender info' do
        expect(mock_mailgun_message_builder).to receive(:from)
          .with('sender@example.com')
      end

      it 'should call mailgun_message_builder.add_recipient with recipient' \
         ' info' do
        expect(mock_mailgun_message_builder).to receive(:add_recipient)
          .with(:to, 'recipient1@example.com')
      end

      it 'should call mailgun_message_builder.subject with subject info' do
        expect(mock_mailgun_message_builder).to receive(:subject)
          .with('Hi')
      end

      it 'should call mailgun_message_builder.body_text with body_text info' do
        expect(mock_mailgun_message_builder).to receive(:body_text)
          .with('Hi there')
      end

      it 'should call mock_mailgun_client' do
        expect(mock_mailgun_client).to receive(:send_message)
          .with('example.com', mock_mailgun_message_builder)
      end
    end

    it 'should update email status' do
      @mailgun_api.send_email(@email)

      expect(@email.recipients[0][:status]).to eq('sent')
    end

    it 'should return status processed' do
      response = @mailgun_api.send_email(@email)

      expect(response[:status]).to eq('processed')
    end
  end

  context 'mailgun executes request unsuccessfully' do
    before do
      allow(mock_mailgun_client).to receive(:send_message)
        .and_return(mock_failure_result)

      @response = @mailgun_api.send_email(@email)
    end

    it 'should not update email status' do
      expect(@email.recipients[0][:status]).to eq('not_sent')
    end

    it 'should return status error' do
      expect(@response[:status]).to eq('error')
    end
  end

  context 'mailgun executes request with an error' do
    before do
      allow(mock_mailgun_client).to receive(:send_message)
        .and_raise(Mailgun::Error)

      @response = @mailgun_api.send_email(@email)
    end

    it 'should not update email status' do
      expect(@email.recipients[0][:status]).to eq('not_sent')
    end

    it 'should return status error' do
      expect(@response[:status]).to eq('error')
    end
  end
end
