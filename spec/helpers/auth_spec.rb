require 'rails_helper'
require 'byebug'

RSpec.describe "Helpers", :type => :helper do
  describe "indieauth_tag" do
    it "returns path to auth interface" do
      tag = %Q[<link rel="authorization_endpoint" href="http://test.host/#{Authorio.authorization_path}">]
      expect(helper.indieauth_tag).to eq(tag)
    end
  end
end
