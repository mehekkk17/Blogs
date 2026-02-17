# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "signup", to: "users#new", as: "signup"
  resources :users, only: %i[ new create ]

  resource :profile, only: %i[ show edit update ], controller: "profile"

  resources :posts, only: %i[ show new create edit update destroy ]
end
