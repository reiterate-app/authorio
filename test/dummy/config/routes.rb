Rails.application.routes.draw do
  root to: "application#index"
  mount Authorio::Engine => "/authorio"
end
