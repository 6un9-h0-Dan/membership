# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  get "/card/new" => "billings#new_card", :as => :add_payment_method
  post "/card" => "billings#create_card", :as => :create_payment_method

  get "/thank-you" => "static_pages#thank_you"

  resources :subscriptions, only: %i[create]
  resources :charges,
    only: %i[new create], path: "donate", path_names: {new: ""}

  namespace :admin do
    get "/dashboard" => "dashboard#index"
    resources :users
    resources :plans
    resources :funds, except: %i[show]
    resources :subscriptions
    resources :donations, only: %i[index show]
  end

  get "/admin", to: redirect("/admin/dashboard")
  get "/users/current" => "users#current", :constraints => {format: "json"}

  resources :user_confirmations, only: %i[index create] do
    post "/confirm" => "user_confirmations#confirm", :on => :collection
  end

  get "/login" => "sessions#login"
  get "/signup" => "sessions#signup"

  if Rails.env.production?
    mount Sidekiq::Web => "/sidekiq",
          :constraints => AdminConstraint.new(require_master: true)
  else
    mount Sidekiq::Web => "/sidekiq"
  end

  root "static_pages#home"
end
