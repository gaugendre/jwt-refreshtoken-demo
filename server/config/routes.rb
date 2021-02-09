Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "home#index"

  devise_for :users

  devise_scope :user do
    namespace :users do
      post '/api/sign_in', to: 'api_sessions#create'
      post '/api/refresh_token', to: 'api_sessions#refresh_token'
      delete '/api/sign_out', to: 'api_sessions#destroy'
    end
  end
end
