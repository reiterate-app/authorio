require 'byebug'

Rails.application.routes.draw do
  root to: "application#index"
  authorio_routes
end
