# frozen_string_literal: true

json.me url_for(@token.authorio_user)
json.client_id @token.client
json.scope @token.scope
