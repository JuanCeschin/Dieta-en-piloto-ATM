Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  resources :daily_targets, only: %i[new create show edit update]

  resources :items, only: %i[index new create edit update destroy] do
    resources :order_items, only: %i[create]
  end
  resources :orders, only: %i[show]

  resources :order_items, only: %i[edit update destroy]
end
