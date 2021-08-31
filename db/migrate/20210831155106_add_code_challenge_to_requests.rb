class AddCodeChallengeToRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :authorio_requests, :code_challenge, :string
  end
end
