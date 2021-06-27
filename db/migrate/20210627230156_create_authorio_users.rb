class CreateAuthorioUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :authorio_users do |t|
      t.string :profile_path
      t.string :password_digest

      t.timestamps
    end
    add_index :authorio_users, :profile_path, unique: true
  end
end
