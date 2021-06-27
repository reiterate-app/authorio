class CreateAuthorioRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :authorio_requests do |t|
      t.string :code
      t.string :redirect_uri
      t.string :client
      t.string :scope
      t.references :authorio_user, null: false, foreign_key: true
      t.string :auth_token

      t.timestamps
    end
    add_index :authorio_requests, :auth_token, unique: true
  end
end
