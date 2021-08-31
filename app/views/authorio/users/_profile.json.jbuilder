# frozen_string_literal: true

json.me profile_url(@auth_request.authorio_user)
if @auth_request.scope&.include? 'profile'
  json.profile do
    json.name(@auth_request.authorio_user.full_name)
    json.call(@auth_request.authorio_user, :url, :photo)
    json.email(@auth_request.authorio_user.email) if @auth_request.scope.include?('email')
  end
end
