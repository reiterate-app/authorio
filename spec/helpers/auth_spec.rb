require 'rails_helper'
require 'byebug'

RSpec.describe "Helpers", :type => :helper do
  describe "indieauth_tag" do
    it "returns path to auth interface" do
      expect(helper.indieauth_tag).to include 'authorization_endpoint'
      expect(helper.indieauth_tag).to include 'token_endpoint'
    end
  end
end
