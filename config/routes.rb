# frozen_string_literal: true

Rails.application.routes.draw do
  apipie
  get '/current_user', to: 'current_user#index'

  namespace :api do
    namespace :v1 do
      resources :orders, param: :payment_id, only: %i[index show create destroy]
      get '/orders/:payment_id/transactions', to: 'orders#cancel'
    end
  end

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
