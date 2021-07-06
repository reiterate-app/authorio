FactoryBot.define do
	factory :user, :class => Authorio::User do
		profile_path { "/" }
		password { 'password' }
	end
end
