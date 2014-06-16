Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root 'application#home'

  resources :users
  resources :tasks
  resources :certificates
end
