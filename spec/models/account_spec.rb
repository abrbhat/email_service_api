require 'rails_helper'

RSpec.describe Account, type: :model do
  it "should not be valid if no api key is present" do
    account = Account.new

    expect(account.valid?).to eq false
  end

  it "should be valid if api key is present" do
    account = Account.new(api_key: "api_key_1")

    expect(account.valid?).to eq true
  end
end
