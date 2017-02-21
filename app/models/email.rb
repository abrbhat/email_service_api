class Email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :subject, :body, :to, :cc, :bcc
  attr_reader :errors

  def initialize(parameters = {})
    @errors = Set.new

    parameters.each do |key, value|
      instance_variable_set("@#{key}", value) unless value.nil?
    end

    # Initiliazing subject and body to empty strings
    self.subject ||= ""
    self.body ||= ""

    # Ensuring email.recipients is always an array
    self.to = Array(self.to)
    self.cc = Array(self.cc)
    self.bcc = Array(self.bcc)
  end

  def dispatch
    return false if not is_valid?

    # Choosing the order of service providers randomly each time
    # It will help in distributing the load across various services
    service_providers = ServiceProvider::Base.list.shuffle

    # Try sending the email with each service provider one by one
    service_providers.each do |service_provider|
      response = "ServiceProvider::#{service_provider}".constantize.send(self)

      next if response.blank?

      # Return on first success, else retry with another service_provider
      return true if response[:status] == "sent_mail"
    end

    # Return error if email could not be sent with any service provider
    return false
  end

  private

  def recipients
    self.to + self.cc + self.bcc
  end

  def is_valid?
    if recipients.blank?
      self.errors << "no_recipient_present"
      return false
    elsif (invalid_emails = recipients
                            .reject{|recipient| recipient =~ VALID_EMAIL_REGEX}
          ).present?
      self.errors << "invalid_emails:#{invalid_emails.join(",")}"
      return false
    end

    return true
  end
end
