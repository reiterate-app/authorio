# frozen_string_literal: true

json.me profile_url(request.authorio_user)
if request.scope&.include? 'profile'
  json.profile do
    json.name(request.authorio_user.full_name)
    json.call(request.authorio_user, :url, :photo)
    json.email(request.authorio_user.email) if request.scope.include?('email')
  end
end
