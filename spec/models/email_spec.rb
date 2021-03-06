require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe Email, type: :model do
  describe 'initialization' do
    it 'assign the subject and body parameters to the object attributes' do
      email_parameters = {
        subject: 'Hi there',
        body: 'How are you?'
      }

      email = Email.new(email_parameters)

      expect(email.subject).to eq(email_parameters[:subject])
      expect(email.body).to eq(email_parameters[:body])
    end

    it 'creates status objects for recipients' do
      email_parameters = {
        subject: 'Hi there',
        body: 'How are you?',
        to: ['alice@example.com'],
        cc: ['bob@example.com'],
        bcc: 'trudy@example.com'
      }

      email = Email.new(email_parameters)

      recipient_emails = email_parameters[:to] +
                         email_parameters[:cc] +
                         [email_parameters[:bcc]]

      expect(email.recipients.length).to eq 3
      expect(email.recipients.map { |r| r[:email_id] } - recipient_emails)
        .to eq []
      expect(email.recipients.map { |r| r[:status] }.uniq).to eq ['not_sent']
    end

    it 'creates sets rejected in status objects for invalid emails' do
      email_parameters = {
        subject: 'Hi there',
        body: 'How are you?',
        to: ['alice_no_email']
      }

      email = Email.new(email_parameters)

      expect(email.recipients.length).to eq 1
      expect(email.recipients[0][:status]).to eq 'rejected'
      expect(email.recipients[0][:error]).to eq 'invalid_email_id'
    end

    it 'initializes subject and body to an empty string if none present' do
      email = Email.new

      expect(email.subject).to eq('')
      expect(email.body).to eq('')
    end

    it 'initializes recipients and attachments to arrays if not already' \
       ' arrays' do
      email = Email.new

      expect(email.recipients).to eq([])
      expect(email.attachments).to eq([])
    end

    it 'removes duplicate email ids' do
      email = Email.new(
        to: ['alice@example.com', 'alice@example.com'],
        cc: ['alice@example.com']
      )

      expect(email.recipients.length).to eq(1)
    end
  end

  describe 'dispatch' do
    let(:valid_parameters) do
      {
        subject: 'Hi Alice',
        body: 'Just saying hi.',
        to: ['alice@example.com']
      }
    end

    context 'invalid email' do
      it 'should return false' do
        email = Email.new

        expect(email.dispatch).to eq false
      end
    end

    context 'valid email' do
      before do
        @email = Email.new(valid_parameters)

        MockServiceProviderSuccessfulSend = Struct.new('MockServiceProvider') do
          def send_email(email)
            email.recipients.each do |recipient|
              recipient[:status] = 'sent'
            end
          end
        end

        allow(@email).to receive(:get_service_provider)
          .and_return(MockServiceProviderSuccessfulSend.new)
      end

      it 'should return true if service provider processes all email' \
         ' succcessfully' do
        expect(@email.dispatch).to eq true
      end

      context 'unsuccessful response' do
        before do
          @email = Email.new(valid_parameters)

          MockServiceProviderUnsuccessfulSend =
            Struct.new('MockServiceProvider') do
              def send_email(_email); end
            end

          allow(@email).to receive(:get_service_provider)
            .and_return(MockServiceProviderUnsuccessfulSend.new)
        end

        it 'should return false if service provider does not return a success' \
           ' response' do
          expect(@email.dispatch).to eq false
        end
      end
    end
  end

  describe 'valid?' do
    context 'no recipients present' do
      before do
        @email = Email.new(
          subject: 'Hi',
          body: 'Hi there.'
        )
      end

      it 'returns false' do
        expect(@email.valid?).to eq false
      end

      it 'should add error to email' do
        @email.valid?

        expect(@email.errors.count).to eq 1
        expect(@email.errors.to_a[0]).to eq 'no_recipient_present'
      end
    end

    context 'subject is not present' do
      before do
        @email = Email.new(
          body: 'Hi there.',
          to: 'alice@example.com'
        )
      end

      it 'returns false' do
        expect(@email.valid?).to eq false
      end

      it 'should add error to email' do
        @email.valid?

        expect(@email.errors.count).to eq 1
        expect(@email.errors.to_a[0]).to eq 'no_subject_present'
      end
    end

    context 'body is not present' do
      before do
        @email = Email.new(
          subject: 'Hi',
          to: 'alice@example.com'
        )
      end

      it 'returns false' do
        expect(@email.valid?).to eq false
      end

      it 'should add error to email' do
        @email.valid?

        expect(@email.errors.count).to eq 1
        expect(@email.errors.to_a[0]).to eq 'no_body_present'
      end
    end

    context 'email is valid' do
      it 'returns true if email is valid' do
        email = Email.new(
          subject: 'Hi',
          body: 'Hi there!',
          to: 'alice@example.com'
        )

        expect(email.valid?).to eq true
      end
    end
  end
end
