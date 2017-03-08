# Account model
class Account < ApplicationRecord
  validates :api_key,
            presence: true
end
