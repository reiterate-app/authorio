class AddProfileToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :authorio_users, :email, :string
    add_column :authorio_users, :full_name, :string
    add_column :authorio_users, :url, :string
    add_column :authorio_users, :photo, :string
  end
end
