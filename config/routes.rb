Rails.application.routes.draw do
  resources :results
  resources :runners
  resources :clubs
  resources :categories
  resources :groups
  devise_for :users
  resources :competitions
  get 'home/index'
  post 'result/modal_new', to: 'results#modal_new', as: "modal_result"

  root "home#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
