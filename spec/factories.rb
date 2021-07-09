FactoryBot.define do
	factory :user, class: Authorio::User do
		profile_path { "/" }
		password { 'password' }
	end

	factory :request, class: Authorio::Request do
		code { 'deadbeef' }
		redirect_uri { 'https://example.net/redirect/' }
		client { 'https://example.net/' }
		authorio_user { association :user }
	end
end