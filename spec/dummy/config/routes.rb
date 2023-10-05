# frozen_string_literal: true

Rails.application.routes.draw do
  scope "(:locale)", locale: /en|zh/ do
    resources :decorated_posts, only: [:show], controller: 'decorator' do
      get "mail", on: :member
    end
  end

  resources :comments
  resources :authors
  resources :posts
end
