class ChangePathToUsernameInUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :authorio_users do |t|
      t.rename :profile_path, :username
    end
  end
end
