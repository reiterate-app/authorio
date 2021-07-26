class CreateAuthorioSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :authorio_sessions do |t|
      t.references :authorio_user, null: false, foreign_key: true
      t.string :selector
      t.string :hashed_token
      t.datetime :expires_at
      t.timestamps
    end
  end
end

