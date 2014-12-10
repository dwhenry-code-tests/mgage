Rails.application.routes.draw do

  resources :campaigns, only: [:index, :show]

  root "campaigns#index"
end
