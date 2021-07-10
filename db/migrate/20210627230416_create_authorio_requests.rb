class CreateAuthorioRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :authorio_requests do |t|
      t.string :code
      t.string :redirect_uri
      t.string :client
      t.string :scope
      t.references :authorio_user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
