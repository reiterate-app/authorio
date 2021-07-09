def json
    ActiveSupport::JSON.decode @response.body
end

def client_redirect_uri
    'https://example.net/redirect/'
end
