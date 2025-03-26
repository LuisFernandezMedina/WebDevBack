Rails.application.routes.draw do
  
  post '/signup', to: 'users#create'
  post '/login', to: 'users#login'
  post '/users/request_money', to: 'users#request_money'
  get '/profile', to: 'users#show'
  get 'users/email/:email', to: 'users#show_by_email'
  post '/users/:id/add_balance', to: 'users#add_balance'
  post '/users/:id/retire_balance', to: 'users#retire_balance'
    
  resources :users, only: [:show, :update, :destroy]
  resources :payment_cards, only: %i[index show create update destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
