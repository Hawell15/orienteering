Rails.application.routes.draw do
  resources :results
  resources :runners
  resources :clubs
  resources :categories
  resources :groups
  devise_for :users
  resources :competitions
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
