class AddExpiryToTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :authorio_tokens, :expires_at, :datetime
  end
end
