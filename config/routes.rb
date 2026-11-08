Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  root "home#index"
  get "search", to: "search#index"
  resource :preference, only: :update

  resources :users, only: :index
  resources :tags, only: :index

  resources :inventories, except: :index do
    collection { delete :bulk_destroy }
    member { post :custom_id_preview }

    resources :items, only: %i[index new create show update] do
      collection { delete :bulk_destroy }
      resource :like, only: %i[create destroy]
    end
    resources :comments, only: :create
    resources :accesses, only: :create do
      collection { delete :bulk_destroy }
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
