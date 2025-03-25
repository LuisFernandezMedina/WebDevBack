Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post '/signup', to: 'users#create'
  post '/login', to: 'users#login'
  post '/users/request_money', to: 'users#request_money'
  get '/profile', to: 'users#show'
  get 'users/email/:email', to: 'users#show_by_email'
    
  resources :users, only: [:show, :update, :destroy]
  resources :payment_cards, only: %i[index show create update destroy]
  
    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
