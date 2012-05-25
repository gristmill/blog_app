BlogApp::Application.routes.draw do
  resources :posts

  resources :comments, :only => :create

  root :to => 'home#index'
end