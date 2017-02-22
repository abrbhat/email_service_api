class Email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :subject, :body, :recipients, :attachments, :status
  attr_reader :errors

  @@status_list = %w{not_sent sent queued rejected}

  def initialize(parameters = {})
    @errors = Set.new

    # Initiliazing defaults
    self.subject = parameters[:subject] || ""
    self.body = parameters[:body] || ""
    self.attachments = Array(parameters[:attachments])
    self.recipients = []

    [:to, :cc, :bcc].each do |attribute|
      Array(parameters[attribute]).each do |recipient_email_id|
        self.recipients <<
          if recipient_email_id =~ VALID_EMAIL_REGEX
            {
              email_id: recipient_email_id,
              type: attribute.to_s,
              status: "not_sent",
              error: nil
            }
          else
            {
              email_id: recipient_email_id,
              type: attribute.to_s,
              status: "rejected",
              error: "invalid_email_id"
            }
          end
      end
    end
  end

  def dispatch
    return false if not is_valid?

    # Choosing the order of service providers randomly each time
    # It will help in distributing the load across various services
    service_providers = ServiceProvider::Base.list.shuffle

    # Try sending the email with each service provider one by one
    service_providers.each do |service_provider|
      "ServiceProvider::#{service_provider}".constantize.send_email(self)

      # Return true if there are no more recipients to whom mail has not been sent
      return true if self.not_sent_to_recipients.blank?
    end

    return false
  end

  def not_sent_to_recipients
    self.recipients.select{|recipient| recipient[:status] == "not_sent"}
  end

  def is_valid?
    if recipients.blank?
      self.errors << "no_recipient_present"
    elsif subject.blank?
      self.errors << "no_subject_present"
    elsif body.blank?
      self.errors << "no_body_present"
    end

    if self.errors.present?
      self.status = "error"
      return false
    end

    return true
  end

  private

end
