# PORO for email
class Email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :subject, :body, :recipients, :attachments, :status
  attr_reader :errors

  @status_list = %w(not_sent sent queued rejected)

  def initialize(parameters = {})
    @errors = Set.new

    # Initiliazing defaults
    self.subject = parameters[:subject] || ''
    self.body = parameters[:body] || ''
    self.attachments = Array(parameters[:attachments])
    self.recipients = []

    add_recipients(parameters)
  end

  def dispatch
    return false unless valid?

    # Choosing the order of service providers randomly each time
    # It will help in distributing the load across various services
    service_providers = ServiceProvider::Base.list.shuffle

    # Try sending the email with each service provider one by one
    service_providers.each do |service_provider|
      "ServiceProvider::#{service_provider}".constantize.send_email(self)

      # Return true if there are no more recipients to whom mail
      # has not been sent
      return true if not_sent_to_recipients.blank?
    end

    false
  end

  def update_delivery_statuses(delivery_statuses = {})
    recipients.each do |recipient|
      if delivery_statuses.key? recipient[:email_id]
        recipient[:status] = delivery_statuses[recipient[:email_id]]
      end
    end
  end

  def not_sent_to_recipients
    recipients.select { |recipient| recipient[:status] == 'not_sent' }
  end

  def valid?
    validate

    if errors.present?
      self.status = 'error'
      return false
    end

    true
  end

  def validate
    if recipients.blank?
      errors << 'no_recipient_present'
    elsif subject.blank?
      errors << 'no_subject_present'
    elsif body.blank?
      errors << 'no_body_present'
    end
  end

  private

  def add_recipients(parameters)
    recorded_recipients = Set.new

    [:to, :cc, :bcc].each do |attribute|
      Array(parameters[attribute]).each do |recipient_email_id|
        # Checking for duplicate emails
        next if recipient_email_id.in? recorded_recipients

        recorded_recipients << recipient_email_id

        recipients << get_recipient_object(recipient_email_id, attribute)
      end
    end
  end

  def get_recipient_object(email_id, attribute)
    if email_id =~ VALID_EMAIL_REGEX
      email_not_sent(email_id, attribute)
    else
      invalid_email(email_id, attribute)
    end
  end

  def email_not_sent(email_id, attribute)
    {
      email_id: email_id,
      type: attribute.to_s,
      status: 'not_sent',
      error: nil
    }
  end

  def invalid_email(email_id, attribute)
    {
      email_id: email_id,
      type: attribute.to_s,
      status: 'rejected',
      error: 'invalid_email_id'
    }
  end
end
