Rails.application.routes.draw do
  post '/signup', to: 'users#create'
  post '/login', to: 'users#login'
  post '/users/request_money', to: 'users#request_money'
  get '/profile', to: 'users#show'
  get 'users/email/:email', to: 'users#show_by_email'
  get '/users/:user_id/requests', to: 'requests#index'

  resources :users, only: [:index, :show, :update, :destroy] do
    member do
      patch 'add_balance'
      patch 'retire_balance'
      get 'transactions'
    end
    collection do
      post 'transfer_money'
    end
  end
  
  resources :payment_cards, only: %i[index show create update destroy]

  resources :group_requests, only: [:create] do
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
