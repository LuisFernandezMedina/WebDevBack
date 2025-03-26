Rails.application.routes.draw do
  
  post '/signup', to: 'users#create'
  post '/login', to: 'users#login'
  post '/users/request_money', to: 'users#request_money'
  get '/profile', to: 'users#show'
  get 'users/email/:email', to: 'users#show_by_email'
    
  resources :users, only: [:show, :update, :destroy]
  resources :payment_cards, only: %i[index show create update destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
