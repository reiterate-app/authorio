class CreateAuthorioTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :authorio_tokens do |t|
      t.string :client
      t.string :scope
      t.references :authorio_user, null: false, foreign_key: true
      t.string :auth_token

      t.timestamps
    end
    add_index :authorio_tokens, :auth_token, unique: true
  end
end
