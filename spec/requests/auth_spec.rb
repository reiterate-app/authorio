require 'rails_helper'

RSpec.describe "Requests", type: :request do
  it "renders the authroization interface" do
    get "/authorio/auth"
    expect(response.body).
      to include("Authorio")
  end
end
