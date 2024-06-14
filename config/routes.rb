Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # root "images#show"
  ALLOW_ALL = /.+/.freeze

  get 'image-server/:identifier/:region/:size/:rotation/:quality',
    defaults: { format: 'jpg' },
    constraints: { identifier: ALLOW_ALL },
    to: 'images#show'

    get 'image-server/:identifier/info.json',
    constraints: { identifier: ALLOW_ALL },
    to: 'info#show'
end
