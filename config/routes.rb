Rails.application.routes.draw do
  resources :relay_results
  resources :entries do
    member do
      patch :confirm
      delete :reject
      patch :pending
    end
  end
  post 'results/from_competition'
  resources :results
  get 'runners/license'
  get 'runners/update_profile', to: 'runners#update_profile'

  resources :runners do
    collection do
      post 'license'
    end

    member do
      post :merge
    end
  end
  resources :clubs do
       member do
      post :merge
    end
  end

  get 'categories/expired', to: 'categories#expired'
  resources :categories

  get 'groups/pdf'

  resources :groups
  devise_for :users
  get 'competitions/ecn_ranking'
  resources :competitions do
    member do
      get 'pdf', to: 'competitions#pdf'
      get 'group_clasa', to: 'competitions#group_clasa'
      get 'new_runners', to: 'competitions#new_runners'
      post 'set_ecn', as: 'set_ecn'
      get 'group_ecn_coeficients', to: 'competitions#group_ecn_coeficients'
      post 'group_ecn_coeficients', to: 'competitions#update_group_ecn_coeficients', as: 'update_group_ecn_coeficients'
      post 'group_clasa', to: 'competitions#update_group_clasa', as: 'update_group_clasa'
      get 'ecn_csv', to: 'competitions#ecn_csv', as: 'download_ecn_csv'
    end
  end

  get 'home/index'
  post 'result/modal_new', to: 'results#modal_new', as: "modal_result"

  root "home#index"
  get 'parser/index', as: "parser"
  get 'parser/file_results', as: 'file_results'
  post 'parser/file_results'
  post 'parser/file_relay_results'
  get 'parser/iof_runners', as: 'iof_runners'
  get 'parser/iof_results', as: 'iof_results'
  get 'parser/fos_data', as: 'fos_data'
  get 'parser/sync_fos', as: 'sync_fos'
  post 'groups/count_rang', as: 'count_rang'
end

