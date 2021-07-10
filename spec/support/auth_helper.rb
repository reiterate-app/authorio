def json
    ActiveSupport::JSON.decode @response.body
end

def client_redirect_uri
    'https://example.net/redirect/'
end

def authorization_code
    'deadbeef'
end

RSpec.shared_examples "Endpoint parameters" do |p|
  let(:params) {
    {
      client_id: 'https://example.net/',
      redirect_uri: client_redirect_uri,
      state: '1234567',
      code_challenge: "MzlmNjAwYzZkZjMzNTM2NzQwM2MzNTkwYzUzMDE0MjJkNzkxY2NjYjI4OGZkNDAxNzRjMjE1MTAzMzg0YWQ0YQ==",
      code_challenge_method: 'S256',
      scope: 'profile create',
      me: 'http://localhost/'
    }
  }

  let(:post_params) {
    {
      client: 'https://example.net/',
      url: 'http://example.com/',
      password: 'password'
    }
  }

  let(:verify_params) {
    {
      grant_type: 'authorization_code',
      code: authorization_code,
      client_id: 'https://example.net/',
      redirect_uri: client_redirect_uri,
      code_verifier: 'a6128783714cfda1d388e2e98b6ae8221ac31aca31959e59512c59f5'
    }
  }
end
