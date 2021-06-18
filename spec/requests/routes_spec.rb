require 'rails_helper'
require 'byebug'

RSpec.describe "Routes", type: :routing do
  it "presents authorization interface at advertised location" do
    expect(:get => Authorio.authorization_path).
      to route_to(:controller => Authorio.authorization_path, :action => "authorization_interface")
  end
end
