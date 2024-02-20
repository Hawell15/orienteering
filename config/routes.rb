Rails.application.routes.draw do
  resources :entries do
    member do
      patch :confirm
      delete :reject
      patch :pending
    end
  end
  resources :results
  resources :runners
  resources :clubs
  get 'categories/expired', to: 'categories#expired'
  resources :categories

  resources :groups
  devise_for :users

  resources :competitions do
    member do
      get 'group_clasa', to: 'competitions#group_clasa'
      post 'group_clasa', to: 'competitions#update_group_clasa', as: 'update_group_clasa'
    end
  end

  get 'home/index'
  post 'result/modal_new', to: 'results#modal_new', as: "modal_result"

  root "home#index"
  get 'parser/index', as: "parser"
  get 'parser/file_results', as: 'file_results'
  post 'parser/file_results'
  get 'parser/iof_runners', as: 'iof_runners'
  get 'parser/iof_results', as: 'iof_results'
  get 'parser/fos_data', as: 'fos_data'
  post 'groups/count_rang', as: 'count_rang'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
