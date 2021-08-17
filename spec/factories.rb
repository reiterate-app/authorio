FactoryBot.define do
	factory :user, class: Authorio::User do
		username { "admin" }
		password { 'password' }
		email { 'user@example.com' }
		full_name { 'John Doe' }
		url { 'https://example.com' }
	end

	factory :request, class: Authorio::Request do
		code { 'deadbeef' }
		redirect_uri { 'https://example.net/redirect/' }
		client { 'https://example.net/' }
		authorio_user { association :user }
	end

	factory :token, class: Authorio::Token do
		authorio_user_id { 1 }
		client { 'https://example.net/' }
		scope { 'create update' }
	end
end
