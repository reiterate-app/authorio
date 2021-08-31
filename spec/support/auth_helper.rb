def json
    ActiveSupport::JSON.decode @response.body
end

module Authorio
  module Test
    module Constants
      class << self
        def client_redirect_uri
            'https://example.net/redirect/'
        end

        def authorization_code
            'deadbeef'
        end

        def code_challenge
          "OfYAxt8zU2dAPDWQxTAUIteRzMsoj9QBdMIVEDOErUo"
        end
      end
    end
  end
end

RSpec.shared_examples "Endpoint parameters" do |p|
  let(:params) {
    {
      client_id: 'https://example.net/',
      redirect_uri: Authorio::Test::Constants.client_redirect_uri,
      state: '1234567',
      code_challenge: Authorio::Test::Constants.code_challenge,
      code_challenge_method: 'S256',
      scope: 'profile create',
      me: 'http://localhost/'
    }
  }

  let(:post_params) {
    {
      user: {
        url: 'http://example.com/',
        password: 'password'
      },
      scope: {
        scope: []
      }
    }
  }

  let(:verify_params) {
    {
      grant_type: 'authorization_code',
      code: Authorio::Test::Constants.authorization_code,
      client_id: 'https://example.net/',
      redirect_uri: Authorio::Test::Constants.client_redirect_uri,
      code_verifier: 'a6128783714cfda1d388e2e98b6ae8221ac31aca31959e59512c59f5'
    }
  }
end
