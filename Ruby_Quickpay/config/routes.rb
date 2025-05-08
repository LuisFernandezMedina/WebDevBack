Rails.application.routes.draw do
  get "password_resets/create"
  get "password_resets/validate"
  get "password_resets/update"
  post '/signup', to: 'users#create'
  post '/login', to: 'users#login'
  post '/users/request_money', to: 'users#request_money'
  get '/profile', to: 'users#show'
  get 'users/email/:email', to: 'users#show_by_email'
  get '/users/:user_id/requests', to: 'requests#index'
  get '/group_requests', to: 'group_requests#index'

  # config/routes.rb
  post "/password_resets", to: "password_resets#create"          # enviar email
  get "/password_resets/validate", to: "password_resets#validate" # validar token
  patch "/password_resets", to: "password_resets#update"          # actualizar contraseña
  delete '/group_requests/:id/leave', to: 'group_requests#leave'


  resources :users, only: [:index, :show, :update, :destroy] do
    member do
      patch 'add_balance'
      patch 'retire_balance'
      get 'transactions'
      post 'follow'
      delete 'unfollow'
      get 'friends'
    end
    collection do
      post 'transfer_money'
    end
  end
  
  resources :payment_cards, only: %i[index show create update destroy]

  resources :group_requests, only: [:create, :index] do
    member do
      patch :pay
      get :status
    end
  end
  

  resources :requests, only: [:create] do
    member do
      patch 'accept'
      delete 'reject'
    end
  end

  namespace :admin do
    resources :users, only: [:index, :update, :destroy] do
      member do
        patch :modify_balance
      end
    end

    resources :transactions, only: [:destroy]
  end 

  get "up" => "rails/health#show", as: :rails_health_check
end
