Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  root "home#index"
  resource :preference, only: :update

  get "up" => "rails/health#show", as: :rails_health_check
end
