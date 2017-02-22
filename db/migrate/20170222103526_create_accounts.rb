class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.text "api_key",limit: 65535, null: false
      t.timestamps
    end

    add_index :accounts, :api_key
  end
end
